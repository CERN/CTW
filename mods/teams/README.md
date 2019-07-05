# Teams

* `/team` will say your team.
* `/team list` to list teams.
* `/join name` to join team "name".
* `/t msg` for team speak.

## API

### Team def

```lua
{
	name = "string",
	color = "Color as a color spec string",
    color_hex = 0xFF0000,
    -- custom keys permitted
}
```

### Public API

* teams.get(team_name) -> Team def
  * Get team by name.
* teams.create(team_name, def) -> Team def
  * Creates a team, stores it, and returns it.
* teams.get_by_player(player) -> Team def
  * May return nil.
* teams.set_team(player, team_name)
  * Returns bool to indicate success.
* teams.get_members(team_name) -> List of Players
  * Note: only lists online members.
* teams.chat_send_team(team_name, message)
* teams.load()
  * Loads from mod storage. Creates default teams if none exist.
* teams.save()
  * Saves to mod storage.
