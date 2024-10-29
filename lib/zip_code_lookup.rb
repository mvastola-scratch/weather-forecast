# frozen_string_literal: true

# Singleton class holding a lookup table of zip codes to coordinates
# Since the location is fetched from google client-side, this
# - prevents cache poisoning
#   (otherwise we'd need to trust that client provides accurate zip/lat/long tuples, since caching is done by zip)
# - ensures the coordinates we look up are constant for a given zip code
#   (not super necessary, but otherwise we are caching the forecast for the first lat/lng pair that is requested within a zip)
# - allows us to just cache forecast api requests in faraday
class ZipCodeLookup
  MTX = Mutex.new
  CSV_PATH = Rails.root / "db" / "zip_code_lookup.csv"
  MARSHAL_PATH = CSV_PATH.sub_ext('.cache')
  MARSHAL_TMP_PATH = CSV_PATH.sub_ext(".cache.#{Process.pid}.tmp")

  CSV_CONFIG = {
    headers: true,
    header_converters: %i[downcase symbol],
    converters: %i[integer float] # zip needs to be integer to avoid issues with leading 0s
  }
  class NotFound < RuntimeError; end

  class << self
    def fetch(zip)
      instance.fetch(zip.to_i)
    rescue KeyError => error
      Rails.logger.warn(error.full_message)
      raise ZipCodeLookup::NotFound, "Zip code '#{zip}' could not be found"
    end
    def loaded? = defined?(@instance)
    def instance
      # This implementation ensures thread-safety
      return @instance if defined?(@instance)
      MTX.synchronize { @instance ||= new }
    end
  end

  # Original dataset is CSV, but cache it as JSON and prefer that
  #   Doing this because my benchmark shows load time is 5.96s (CSV), 0.147s (JSON), 0.172s (Marshal)
  #   Using Marshal because JSON doesn't play nice with integer keys in hashes
  def initialize
    # First try to load cache in marshal format
    return if load_table_cache

    # Otherwise load from original csv format
    load_csv
    # Then schedule an async task that dumps the marshaled data
    @cache_task = Concurrent::Promise.new(executor: :io) { write_table_cache }.execute
    # @cache_task.wait! run synchronously (for debugging only)
  end

  attr_reader :data
  delegate_missing_to :data

private
  def load_csv
    require 'csv'

    @data = {}
    CSV.foreach(CSV_PATH, **CSV_CONFIG) do |row|
      @data[row[:zip]] = row.to_h.freeze
    end
  end

  def write_table_cache
    File.write(MARSHAL_TMP_PATH.to_s, Marshal.dump(@data), encoding: 'ASCII-8BIT')
    MARSHAL_TMP_PATH.rename(MARSHAL_PATH)
    true
  rescue StandardError => e
    warn e.full_message
    false
  ensure
    MARSHAL_TMP_PATH.unlink if MARSHAL_TMP_PATH.exist?
  end

  def load_table_cache
    return false unless MARSHAL_PATH.file? && MARSHAL_PATH.size.positive?
    @data = Marshal.load(File.read(MARSHAL_PATH, encoding: 'ASCII-8BIT'))
    true
  rescue StandardError => e
    warn e.full_message
    warn "Deleting #{MARSHAL_PATH}"
    MARSHAL_PATH.unlink if MARSHAL_PATH.file?
    false
  end
end
