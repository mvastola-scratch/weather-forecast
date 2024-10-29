class ForecastsController < ApplicationController
  def index
    respond_to :html
  end

  def show
    zip = params.fetch(:zip)
    @forecast = ForecastFetcher.lookup(zip:)
    respond_to :html

  rescue ForecastFetcher::Error => error
    flash[:error] = "Could not obtain forecast: #{error.message}"
    Rails.logger.warn(error.detailed_message)
    redirect_to action: :index
  end
end
