# frozen_string_literal: true

# To generate mocks:
# - curl -H 'Accept: application/ld+json' 'https://api.weather.gov/points/40.7507,-73.9965' > test/mocks/point-10001.json
# - curl -H 'Accept: application/ld+json' 'https://api.weather.gov/gridpoints/OKX/33,37/forecast' > test/mocks/forecast-10001.json

require "test_helper"
class ForecastTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  FORECAST_MOCK_PATH = Rails.root / 'test/mocks/forecast-10001.json'
  def setup
    @data = Oj.load(FORECAST_MOCK_PATH.read, symbolize_names: true, mode: :rails, bigdecimal_load: :auto)
    @forecast = Forecast.new(cache_hit: false, zip: '10001')
  end

  test "validations pass" do
    assert_equal true, @forecast.valid?
  end
end
