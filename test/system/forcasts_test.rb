require "application_system_test_case"

# FIXME: why isn't this file running?
class ForecastsTest < ApplicationSystemTestCase
  setup do
  end

  test "looking up a forecast" do
    visit search_url
    fill_in 'input[aria-label="Search For a Place"]', with: '95014'
    assert_current_path forecast_url(zip: '95014')
  end


  test "should show Forecast" do
    visit forecast_url(zip: '95014')
    assert_text "Forecast was successfully updated"
  end

end
