# frozen_string_literal: true

class Forecast
  POOL_SIZE = 2 # adjustable if higher load expected
  BASE_URL = "https://api.weather.gov/"
  CACHE_TTL = 30.minutes
  JSON_PARSER_OPTIONS = {
    decoder: Oj,
    symbolize_names: true,
    mode: :rails,
    bigdecimal_load: :auto,
  }

  class << self
    def lookup(zip:)
      location = ZipCodeLookup.fetch(zip)
      cache_hit = true
      forecast = Rails.cache.fetch("forecast/zip/#{zip}", expires_in: CACHE_TTL) do
        cache_hit = false
        lat, lng = location.values_at(*%i[latitude longitude])
        pool.with { |forecaster| forecaster.forecast(lat:, lng:) }
      end
      { location:, forecast:, cache_hit: }
    end

  protected
    def pool = @pool ||= ConnectionPool.new(size: POOL_SIZE) { Forecast.send(:new) }
    private :new
  end

  attr_reader :client
  def initialize
    @client = Faraday.new(BASE_URL) do |f|
      # TODO: make sure this order is correct. Faraday is finicky
      f.response :json, parser_options: JSON_PARSER_OPTIONS
      f.response :logger, Rails.logger, { headers: false, bodies: !Rails.env.production?, errors: true }
      f.response :raise_error
      f.request :retry, max: 3
    end
  end

  def endpoints(lat:, lng:)
    # This caches separately and has a longer cache time because it provides the endpoints that give actual forecasts
    #   per https://www.weather.gov/documentation/services-web-api, this only changes occasionally
    Rails.cache.fetch("forecast/endpoints/#{lat},#{lng}", expires_in: 1.days) do
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
end
