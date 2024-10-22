# frozen_string_literal: true

class Forecast
  POOL_SIZE = 2 # adjustable if higher load expected
  BASE_URL = "https://api.weather.gov/" # TODO:
  CACHE_TTL = 30.minutes
  class << self
    def lookup(zip:)
      Rails.cache.fetch("forecast/zip/#{zip}", expires_in: CACHE_TTL) do
        lat, lng = ZipCodeLookup.fetch(zip).values_at(*%i[latitude longitude])
        pool.with { |forecaster| forecaster.forecast(lat:, lng:) }
      end
    end

  protected
    def pool = @pool ||= ConnectionPool.new(size: POOL_SIZE) { Forecast.new }
    private :new
  end

  attr_reader :client
  def initialize
    @client = Faraday.new(BASE_URL) do |f|
      f.request :retry, max: 3

      f.response :json, parser_options: { decoder: Oj }
      f.response :logger, Rails.logger, { headers: false, bodies: !Rails.env.production?, errors: true }
      f.response :raise_error
    end
  end

  def coordinate_lookup(lat:, lng:)
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
  #   If really needed, we could fetch the hourly forecasts (with key: 'forecastHourly'), and then do
  #     `.group_by { Time.parse(_1['startTime']).to_date }`
  #     `.transform_values { |hours| hours.map { |hour| hour.fetch('temperature') }.compact_blank.minmax }`
  def forecast(key: "forecast", **coords)
    url = coordinate_lookup(**coords).fetch(key)
    resp = @client.get(url) do |req|
      req.headers["Accept"] = "application/ld+json"
    end
    resp.body
  end
end
