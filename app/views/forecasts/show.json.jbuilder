json.cache_hit @cache_hit
json.location do
  json.isDST @location[:daylight_savings_time_flag]&.positive?
  json.timezone @location[:timezone]
  json.longitude @location[:longitude]
  json.latitude @location[:latitude]
  json.state @location[:state]
  json.city @location[:city]
  json.zip @location[:zip]
end
json.forecast do
  json.units @forecast[:units]
  json.forecastGenerator @forecast[:forecastGenerator].underscore
  json.generatedAt @forecast[:generatedAt]
  json.updateTime @forecast[:updateTime]
  json.validTimes @forecast[:validTimes]

  # NOTE: this is a https://schema.org/QuantitativeValue
  #   If we were planning to use this, we should find a gem that parses the object and converts units
  #   Looks like we'd extend the `schema_dot_org` gem to allow for conversion

  json.elevation @forecast[:elevation]

  json.predictions @forecast[:periods], partial: 'forecasts/prediction', as: :prediction
end