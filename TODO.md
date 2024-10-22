# TODO

## Requirements
- [x] Must be done in Ruby on Rails
- [x] Accept an address as input
- [x] Retrieve forecast data for the given address. This should include, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)
- [ ] Display the requested forecast details to the user
- [x] Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator if result is pulled from cache.

## Reminders

- [ ] it’s not just whether or not the code works that they will be focused on seeing – it’s all the rest of what goes into good Senior Software Engineering daily practices for Enterprise Production Level Code – such as specifically:
- [ ] Unit Tests (#1 on the list of things people forget to include – so please remember, treat this as if it were true production level code, do not treat it just as an exercise),
- [ ] Detailed Comments/Documentation within the code, also have a README file
- [ ] Include *Decomposition* of the Objects in the Documentation
- [ ] Design Patterns (if/where applicable)
- [ ] Scalability Considerations (if applicable)
- [ ] Naming Conventions (name things as you would name them in enterprise-scale production code environments)
- [ ] Encapsulation, (don’t have 1 Method doing 55 things)
- [ ] Code Re-Use, (don’t over-engineer the solution, but don’t under-engineer it either)
- [ ] any other industry Best Practices

## Other Ideas

- Store most recent location in cookie(?)
- Switch to importmap(?) (would require removing or stripping typescript)