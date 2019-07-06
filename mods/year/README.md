# Year

## API

* year.get() -> current year (float)
* year.get(tname_or_team) -> technological year team is in.
* year.get_range() -> year range, tuple of (min, max)
* year.register_on_change(func(year_val, leading_team))
  * func() return value is ignored
* year.bump(year, team)
  * Team `team` has bumped the year to `year`.
