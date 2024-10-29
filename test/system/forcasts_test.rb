require "application_system_test_case"

class ForecastsTest < ApplicationSystemTestCase
  setup do
  end

  test "looking up a forecast" do
    visit search_url
    # Capybara apparently won't play nice with the autocomplete input because it's in a shadow DOM
    #   so this is a workaround
    assert_button 'Lookup', disabled: true
    execute_script 'window.setForecastLookupZip(`95014`);'
    assert_button 'Lookup', disabled: false
    click_on 'Lookup'
    assert_current_path forecast_url(zip: '95014')
  end


  test "should show Forecast" do
    ForecastFetcher.with_cache ActiveSupport::Cache::MemoryStore.new do
      visit forecast_url(zip: '95014')
      assert_text "Cupertino, CA Forecast"
      assert_text "Cache Miss"

      visit forecast_url(zip: '10001')
      assert_text "New York, NY Forecast"
      assert_text "Cache Miss"

      visit forecast_url(zip: '95014')
      assert_text "Cupertino, CA Forecast"
      assert_text "Cache Hit"
    end

    within '#forecast-carousel' do
      within '.carousel-inner' do
        assert_selector 'div.forecast-card', between: 1..2
        assert_selector 'img.forecast-image', between: 1..2
        assert_selector '.forecast-name', between: 1..2
        assert_selector '.forecast-temperature', between: 1..2
        assert_selector '.forecast-description', between: 1..2
        assert_selector '.forecast-wind', between: 1..2
        assert_selector '.forecast-precipitation', between: 0..2
      end
      within '.carousel-indicators' do
        assert_selector 'button', count: Forecast::FORECASTED_DAYS
      end
    end
  end

end
