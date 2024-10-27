# TODO

## Missing Features / Bugs 
- **Tests**
- The order of the retry and raise-error handlers in faraday seem to be reversed. (It's raising an error after 1 try)
- Link weather.gov OpenAPI spec in `README.md`


## Requirements
- [x] Must be done in Ruby on Rails
- [x] Accept an address as input
- [x] Retrieve forecast data for the given address. This should include, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)
- [x] Display the requested forecast details to the user
- [x] Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator if result is pulled from cache.

## Reminders

- [ ] Unit Tests (#1 on the list of things people forget to include – so please remember, treat this as if it were true production level code, do not treat it just as an exercise),
- [ ] Detailed Comments/Documentation within the code, also have a README file
- [ ] Include *Decomposition* of the Objects in the Documentation
- [ ] Design Patterns (if/where applicable)
- [ ] Scalability Considerations (if applicable)
- [ ] Naming Conventions (name things as you would name them in enterprise-scale production code environments)
- [x] Encapsulation, (don’t have 1 Method doing 55 things)
- [x] Code Re-Use, (don’t over-engineer the solution, but don’t under-engineer it either)
- [x] any other industry Best Practices

## Wish List

- Encapsulate API responses in a class (ActiveModel?) to avoid unnecessary logic in view/controller
- Implement a server-side autocomplete while retaining as good of a UX
  - This will remove the need to use a dataset, and allow us to search directly by coordinates (right now this isn't secure because we're caching and coordinates are obtained client-side)
- Configure CSP initializer
- Cache weather images locally & preload them all
- Store most recent location in cookie for restore and/or allow selecting location from history
- Use geolocation in browser to optionally fetch users' current location
- Switch to importmap(?) or a more streamlined JS solution (possibly one that doesn't require building)
  - would require removing or stripping TypeScript and SCSS
- Don't require encoding google maps api key into JS (via `Gulpfile.js`)
  - If needed in JS, we can read the value of a meta tag
- Show `README.md`/`TODO.md` in navbar and render the files in a modal box
- Use AJAX and/or React to fetch results as JSON and render on client-side
- Ensure UI is responsive/looks good on smaller screens 