# frozen_string_literal: true

require "test_helper"
class ForecastFetcherTest < ActionDispatch::IntegrationTest
  # TODO: mock sample responses to requests made by ForecastFetcher (use webmock gem), including:
  # - ensure no requests made if forecast is cached
  # - ensure appropriate error raised if mock response reflects an error
  # - ensure attribute values match values returned in json response data
end
