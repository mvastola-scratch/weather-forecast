class ForecastsController < ApplicationController
  def geolocate
    # @location = params[:location] || cookies['last_location']
    respond_to do |format| # TODO: look up the short way of doing this
      format.html
    end
  end

  def forecast
    @forecast = Forecast.fetch(forecast_params)

    respond_to do |format|
      if @forecast.valid?
        format.html { render notice: "Forecast was successfully fetched." }
        format.json { render json: @forecast.data, status: :ok }
      else
        format.html { head :unprocessable_entity }
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
