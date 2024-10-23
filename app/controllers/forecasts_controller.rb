class ForecastsController < ApplicationController
  def index
    respond_to do |format| # TODO: look up the short way of doing this
      format.html
    end
  end

  def show
    zip = params.fetch(:zip)
    # TODO: handle if param is missing
    @location, @forecast, @cache_hit = Forecast.lookup(zip:)
    @forecast[:all_dates] = @forecast[:periods].group_by { Time.parse(_1[:startTime]).to_date }
    # Only show first 3 dates
    @forecast[:dates] = @forecast[:all_dates].to_a.first(3).to_h

    respond_to do |format|
      format.html { render layout: !request.xhr? } # no layout if xhr request
      format.json
    end
  end
end
