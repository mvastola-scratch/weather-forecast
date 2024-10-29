# frozen_string_literal: true

ActiveSupport.on_load(:after_initialize) do
  'ForecastPeriodsType'.constantize # ensure class is loaded without a `require`, which could cause a double-load
  ZipCodeLookup.instance # Eager load zip code db
end

