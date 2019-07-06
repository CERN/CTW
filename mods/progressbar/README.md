# ProgressBar

Used to make HUD progress bars

## API

### Public Static

* `ProgressBar:new()` -> ProgressBar

### Public Methods

* `bar:set_values(values)`
  * Updates data and HUD.
  * Values is a dictionary from color to value.
* `bar:update_hud()`
  * Show hud to all players.
* `bar:update_hud_for_player(values)`
  * Show to player.
* `bar:move_to(offset)`
  * Move to offset.
* `bar:move(offset)`
  * Adds to offset.

### Public Members

* offset
* min
* max
* width
