class ForecastsController < ApplicationController
  def geolocate
    # @location = params[:location] || cookies['last_location']
    respond_to do |format| # TODO: look up the short way of doing this
      format.html
    end
  end

  def fetch
    # cookies['last_location']
    @forecast = Forecast.fetch(forecast_params)

    respond_to do |format|
      if @forecast.save
        format.html { redirect_to @forecast, notice: "Forecast was successfully fetched." }
        format.json { render :show, status: :created, location: @forecast }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @forecast.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def forecast_params
      params.fetch(:forecast, {})
      # params.permit(:forecast).require([:latitude, :longitude])
    end
end
