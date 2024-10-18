// import { Loader } from "@googlemaps/js-api-loader"
import {APILoader} from "@googlemaps/extended-component-library/api_loader.js";

import type { PlacePicker } from "@googlemaps/extended-component-library/place_picker.js";
import type { Place } from "@googlemaps/extended-component-library/lib/utils/googlemaps_types";

const apiKeyMetaTag = document.querySelector('meta#google-maps-api-key') as HTMLMetaElement;
if (!apiKeyMetaTag) {
  console.warn("Expected element matching meta#google-maps-api-key to exist");
}
const GOOGLE_MAPS_API_KEY = apiKeyMetaTag.content;

// {apiKey: "YOUR_API_KEY", version: "weekly"});

// async function initMap(): Promise<void> {
//   // Request needed libraries.
//   //@ts-ignore
//   const places = await loader.importLibrary("places") as google.maps.PlacesLibrary;
//   // Create the input HTML element, and append it.
//   //@ts-ignore
//   const placeAutocomplete = new places.PlaceAutocompleteElement();
//   //@ts-ignore
//   document.body.appendChild(placeAutocomplete);
//
//   // Inject HTML UI.
//   const selectedPlaceTitle = document.createElement('p');
//   selectedPlaceTitle.textContent = '';
//   document.body.appendChild(selectedPlaceTitle);
//
//   const selectedPlaceInfo = document.createElement('pre');
//   selectedPlaceInfo.textContent = '';
//   document.body.appendChild(selectedPlaceInfo);
//
//   // Add the gmp-placeselect listener, and display the results.
//   //@ts-ignore
//   placeAutocomplete.addEventListener('gmp-placeselect', async ({ place }) => {
//     await place.fetchFields({ fields: ['displayName', 'formattedAddress', 'location'] });
//
//     selectedPlaceTitle.textContent = 'Selected Place:';
//     selectedPlaceInfo.textContent = JSON.stringify(
//       place.toJSON(),
//        null, // replacer
//        2 // space
//      );
//   });
// }

/**
 * @license
 * Copyright 2024 Google LLC. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */
// From https://jsfiddle.net/u43pj69g/
async function ComponentInit() {
  const loader = new APILoader({
    apiKey: GOOGLE_MAPS_API_KEY,
    version: "weekly",
  });
  const maps = await APILoader.importLibrary("maps");
  const places = await APILoader.importLibrary("places");
  console.log('Places library loaded')
  await customElements.whenDefined('gmp-map');
  console.log('gmp-map element defined')

  const map = document.querySelector("gmp-map") as google.maps.MapElement;
  if (!map) console.log('gmp-map element not found')
  // @ts-ignore
  const marker = document.getElementById("marker") as google.maps.Marker;
  const strictBoundsInputElement = document.getElementById("use-strict-bounds");
  const placePicker = document.getElementById("place-picker") as PlacePicker;
  const infowindowContent = document.getElementById("infowindow-content");
  const infowindow = new google.maps.InfoWindow();

  map.innerMap.setOptions({mapTypeControl: false});
  infowindow.setContent(infowindowContent);

  placePicker.addEventListener('gmpx-placechange', () => {
    if (!placePicker.value) return;
    const place: Place = placePicker.value;

    if (!place.location) {
      // @ts-ignore
      window.alert("No details available for input: '" + (place.name || 'unknown name') + "'");
      infowindow.close();
      // @ts-ignore
      marker.position = null;
      return;
    }

    if (place.viewport) {
      map.innerMap.fitBounds(place.viewport);
    } else {
      map.center = place.location;
      map.zoom = 17;
    }

    // @ts-ignore
    marker.position = place.location;
    // @ts-ignore
    infowindowContent.children["place-name"].textContent = place.displayName;
    // @ts-ignore
    infowindowContent.children["place-address"].textContent = place.formattedAddress;
    infowindow.open(map.innerMap, marker);
  });

  // @ts-ignore
  strictBoundsInputElement.addEventListener("change", () => {
    // @ts-ignore
    placePicker.strictBounds = strictBoundsInputElement.checked;
  });
}

// document.addEventListener('DOMContentLoaded', ComponentInit);

export { ComponentInit };
