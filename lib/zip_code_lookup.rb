# frozen_string_literal: true

require 'csv'
# Singleton class holding a lookup table of zip codes to coordinates
# Since the location is fetched from google client-side, this
# - prevents cache poisoning
#   (otherwise we'd need to trust that client provides accurate zip/lat/long tuples, since caching is done by zip)
# - ensures the coordinates we look up are constant for a given zip code
#   (not super necessary, but otherwise we are caching the forecast for the first lat/lng pair that is requested within a zip)
# - allows us to just cache forecast api requests in faraday
class ZipCodeLookup
  MTX = Mutex.new
  DB_PATH = Rails.root / "db" / "zip_code_lookup.csv"
  CSV_CONFIG = {
    headers: true,
    header_converters: %i[downcase symbol],
    converters: %i[integer float]
  }
  class << self
    delegate :fetch, to: :instance
    def loaded? = defined?(@instance)
    def instance
      # This implementation ensures thread-safety
      return @instance if defined?(@instance)
      MTX.synchronize { @instance ||= new }
    end
  end

  def initialize
    @data = {}
    CSV.foreach(DB_PATH, **CSV_CONFIG) do |row|
      @data[row[:zip]] = row.to_h.freeze
    end
    @data.freeze
  end

  attr_reader :data
  delegate_missing_to :data
end
