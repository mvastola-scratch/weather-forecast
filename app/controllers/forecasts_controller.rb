class ForecastsController < ApplicationController

  rescue_from ForecastFetcher::Error do |error|
    flash[:error] = "Could not obtain forecast: #{error.message}"
    Rails.logger.warn(error.detailed_message)
    redirect_to action: :index
  end

  def index
    respond_to :html
  end

  def show
    @zip = params.fetch(:zip)
    @forecast = ForecastFetcher.lookup(zip: @zip)
    respond_to :html
  end
end
