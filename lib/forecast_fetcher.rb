# frozen_string_literal: true

class ForecastFetcher
  POOL_SIZE = 2 # adjustable if higher load expected
  BASE_URL = "https://api.weather.gov/"
  CACHE_TTL = 30.minutes
  JSON_PARSER_OPTIONS = {
    decoder: Oj,
    symbolize_names: true,
    mode: :rails,
    bigdecimal_load: :auto,
  }

  class Error < RuntimeError; end
  class NotFound < Error; end
  class RequestFailed < Error; end

  class << self
    def lookup(zip:)
      location = ZipCodeLookup.fetch(zip)
      cache_hit = true
      forecast_data = cache.fetch("forecast/zip/#{zip}", expires_in: CACHE_TTL) do
        cache_hit = false
        lat, lng = location.values_at(*%i[latitude longitude])
        pool.with { |forecaster| forecaster.forecast(key: :forecast, lat:, lng:) }
      end
      Forecast.new(zip:, cache_hit:, **forecast_data)
    rescue ZipCodeLookup::NotFound, Faraday::ClientError => error
      Rails.logger.warn(error.full_message) # TODO: is this redundant?
      raise ForecastFetcher::NotFound, "Could not fetch forecast for #{zip}"
    rescue Faraday::ServerError => error
      Rails.logger.warn(error.full_message) # TODO: is this redundant?
      raise ForecastFetcher::RequestFailed, "Error from remote server when fetching forecast for #{zip}"
    end

    # Used for debugging
    def cache = @cache ||= Rails.cache
    attr_writer :cache
    def with_cache(temp_cache, &block)
      old_cache, @cache = @cache, temp_cache
      begin
        yield
      ensure
        @cache = old_cache
      end
    end

    def without_cache(&block) = with_cache(ActiveSupport::Cache::NullStore.new, &block)

  protected
    def pool = @pool ||= ConnectionPool.new(size: POOL_SIZE) { ForecastFetcher.send(:new) }
    private :new
  end

  attr_reader :client
  def initialize
    @client = Faraday.new(BASE_URL) do |f|
      # TODO: make sure this order is correct. Faraday is finicky
      f.response :json, parser_options: JSON_PARSER_OPTIONS

      f.request :retry, max: 3
      f.response :logger, Rails.logger, { headers: false, bodies: !Rails.env.production?, errors: true }
      f.response :raise_error
    end
  end

  def endpoints(lat:, lng:)
    # This caches separately and has a longer cache time because it provides the endpoints that give actual forecasts.
    #   Per https://www.weather.gov/documentation/services-web-api, this only changes occasionally
    cache.fetch("forecast/endpoints/#{lat},#{lng}", expires_in: 1.days) do
      resp = @client.get("/points/#{lat.round(4)},#{lng.round(4)}") do |req|
        req.headers["Accept"] = "application/ld+json"
      end
      resp.body
    end
  end

  # TODO: make sure current weather data is included
  # NOTE: Oddly, highs/lows are in the spec, but not in the output
  #   They are, however, in the text descriptions of the forecasts
  #   If really needed, we could fetch the hourly forecasts (with key: :forecastHourly), and then do
  #     `.group_by { Time.parse(_1[:startTime]).to_date }`
  #     `.transform_values { |hours| hours.map { |hour| hour.fetch(:temperature) }.compact_blank.minmax }`
  def forecast(key: :forecast, **coords)
    url = endpoints(**coords).fetch(key)
    resp = @client.get(url) do |req|
      req.headers["Accept"] = "application/ld+json"
    end
    resp.body
  end

  delegate :cache, to: :class
end
