import { runOnReady } from "./utils";
import { APILoader } from '@googlemaps/extended-component-library/api_loader.js';
import { PlacePicker } from '@googlemaps/extended-component-library/place_picker.js';

const setupLocationAutocomplete = async () => {
  console.log('Running setupLocationAutocomplete');
  const rootElement = document.querySelector('#location-autocomplete');
  if (!rootElement) throw new Error('No #location-autocomplete found');

  const mapsLoader = new APILoader();
  mapsLoader.apiKey = GOOGLE_MAPS_API_KEY;
  const placesLibrary = await APILoader.importLibrary("places") as google.maps.PlacesLibrary;
  const placeAutocomplete = new google.maps.places.PlaceAutocompleteElement({});
  // @ts-ignore
  placeAutocomplete.addEventListener('gmp-placeselect', async ({ place }: PlaceAutocompletePlaceSelectEvent) => {
    await place.fetchFields({ fields: ['displayName', 'formattedAddress', 'location'] });
    console.log(place);
  });
  rootElement.appendChild(placeAutocomplete);

  console.log('setupLocationAutocomplete complete');
};


runOnReady(setupLocationAutocomplete);


