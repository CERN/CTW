# Era

Value for current (game time) era is based on year mod's `year.get()` and era definitions.

## API

* `era.get(year)` -> get era definition for any given year
* `era.get_current()` -> get era definition for current (game time) year
* `era.register(startyear, endyear, era_definition)` -> register a new era; should normally only be used internally
