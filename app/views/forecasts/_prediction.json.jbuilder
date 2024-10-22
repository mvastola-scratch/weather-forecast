json.number prediction[:number]
json.name prediction[:name]
json.startTime Time.parse(prediction[:startTime])
json.endTime Time.parse(prediction[:endTime])
json.isDaytime prediction[:isDaytime]
json.temperature prediction[:temperature]
json.temperatureUnit prediction[:temperatureUnit]
json.probabilityOfPrecipitation prediction[:probabilityOfPrecipitation]&.fetch(:value)
json.windSpeed prediction[:windSpeed]
json.windDirection prediction[:windDirection]
json.icon prediction[:icon]
json.shortForecast prediction[:shortForecast]
json.detailedForecast prediction[:detailedForecast]

# Example:
# {
#   "number"=>1,
#   "name"=>"Tonight",
#   "startTime"=>"2024-10-21T21:00:00-04:00",
#   "endTime"=>"2024-10-22T06:00:00-04:00",
#   "isDaytime"=>false,
#   "temperature"=>61,
#   "temperatureUnit"=>"F",
#   "temperatureTrend"=>"",
#   "probabilityOfPrecipitation"=>{"unitCode"=>"wmoUnit:percent", "value"=>nil},
#   "windSpeed"=>"6 mph",
#   "windDirection"=>"W",
#   "icon"=>"https://api.weather.gov/icons/land/night/few?size=medium",
#   "shortForecast"=>"Mostly Clear",
#   "detailedForecast"=>"Mostly clear, with a low around 61. West wind around 6 mph."
# }