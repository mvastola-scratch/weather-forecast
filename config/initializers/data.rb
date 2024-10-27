# frozen_string_literal: true


ActiveSupport.on_load(:active_model) do
  ActiveModel::Type.register(:forecast_periods, ForecastPeriodsType)
end

ActiveSupport.on_load(:after_initialize) do
  ZipCodeLookup.instance # Eager load zip code db
end

