# README

A simple Rails app that looks up weather forecasts

# Usage Instructions

**To Launch**

_First, you must obtain the `master.key` file from the author for the Google Maps API Key_

```bash
$ bundle install
$ yarn install
$ yarn build 
$ bundle exec rails s
```

## Routes
```
Prefix      Verb URI Pattern                Controller#Action
root        GET  /                          redirect(301, /forecast)
search      GET  /forecast(.:format)        forecasts#index
forecast    GET  /forecast/:zip(.:format)   forecasts#show
```

## APIs Consumed

**TODO: Simplify this list of URLS**

### Geocoding

- Google Maps Places API 

#### Documentation

- https://developers.google.com/maps/documentation/places/web-service/autocomplete
- https://developers.google.com/maps/documentation/javascript/load-maps-js-api#dynamic-library-import

#### Example Code

- https://github.com/googlemaps/js-samples/blob/d0181aedb93364227da417c9d2765784d9333646/dist/samples/place-autocomplete-element/app/index.ts
- https://github.com/googlemaps/extended-component-library
- https://jsfiddle.net/u43pj69g/
- https://github.com/googlemaps/extended-component-library/tree/main/examples/react_sample_app/src
- https://visgl.github.io/react-google-maps/docs
- https://developers.google.com/maps/documentation/javascript/examples/rgm-college-picker


### Weather Forecasts

Weather.gov's Forecast API

#### Documentation

- https://www.weather.gov/documentation/services-web-api


