import { runOnReady } from "./utils";
import { APILoader } from '@googlemaps/extended-component-library/api_loader.js';
import { PlacePicker } from '@googlemaps/extended-component-library/place_picker.js';
import PlaceAutocompletePlaceSelectEvent = google.maps.places.PlaceAutocompletePlaceSelectEvent;

const getAPIKey = () => {
  const metaTag: HTMLMetaElement|null = document.querySelector('meta[name="google-maps-api-key"]');
  return metaTag?.innerText?.trim();
}

const autocompleteCb = async (e: PlaceAutocompletePlaceSelectEvent) => {
  const { place } = e;
  await place.fetchFields({ fields: ['displayName', 'formattedAddress', 'location', 'addressComponents'] });
  const zipComponents = place.addressComponents?.filter(ac => {
    return ac.types.includes('postal_code')
  })
  const zip = zipComponents ? zipComponents[0]?.shortText : null;
  console.log([place, zip]);
  // TODO: this sort of makes the 'Lookup button useless, but at the same time,
  //  google doesn't seem to offer an event when the value of the textbox is cleared,
  //  so if we relied on the button, it wouldn't always be in-sync with the text box
  if (zip) {
    document.location.pathname = `/forecast/${zip}`;
  } else {
    alert("US Zip Code required. Please provide an exact address within the US.")
  }
}
const setupLocationAutocomplete = async () => {
  const rootElement = document.querySelector('#location-autocomplete');
  if (!rootElement) {
    console.warn('No #location-autocomplete found. Will not setup autocomplete prompt');
    return;
  }

  console.log('Running setupLocationAutocomplete');
  const mapsLoader = new APILoader();
  // TODO: see if this is still needed in the JS
  mapsLoader.apiKey = getAPIKey();
  const placesLibrary = await APILoader.importLibrary("places") as google.maps.PlacesLibrary;
  const placeAutocomplete = new google.maps.places.PlaceAutocompleteElement({});
  placeAutocomplete.addEventListener('gmp-placeselect', autocompleteCb as (e: Event) => unknown);
  rootElement.appendChild(placeAutocomplete);

  console.log('setupLocationAutocomplete complete');
};


runOnReady(setupLocationAutocomplete);


