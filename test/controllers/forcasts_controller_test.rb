require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  setup do
  end

  test "should get index" do
    get search_url
    assert_response :success
  end

  test "should show forecast" do
    get forecast_url(zip: '95014')
    assert_response :success
  end
end
