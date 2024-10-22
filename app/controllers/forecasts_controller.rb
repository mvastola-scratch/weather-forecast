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

    respond_to do |format|
      format.html { render layout: !request.xhr? } # no layout if xhr request
      format.json
    end
  end
end
