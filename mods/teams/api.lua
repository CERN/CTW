local _team_by_name = {}
local _registered_on_team_changed = {}
local _registered_on_points_changed = {}

function teams.get(tname)
	return _team_by_name[tname]
end

function teams.get_points(tname)
	return _team_by_name[tname].points
end

function teams.add_points(tname, v)
	local team = teams.get(tname)
	local points = team.points + v
	team.points = points


	for i=1, #_registered_on_points_changed do
		_registered_on_points_changed[i](team, v)
	end

	return points
end

function teams.get_all(tname)
	local list = {}
	for _, team in pairs(_team_by_name) do
		list[#list + 1] = team
	end
	return list
end

function teams.create(def)
	assert(type(def) == "table")
	assert(type(def.name) == "string", "Team needs a name!")
	assert(def.name == string.lower(def.name), "Team name must be lowercase!")
	assert(not _team_by_name[def.name], "Team already exists")

	_team_by_name[def.name] = def
	def.points = def.points or 0

	return def
end

function teams.get_by_player(player)
	if type(player) == "string" then
		player = minetest.get_player_by_name(player)
		if not player then
			return nil
		end
	end

	local tname = player:get_meta():get_string("team")
	return _team_by_name[tname]
end

function teams.set_team(player, tname)
	if type(player) == "string" then
		player = minetest.get_player_by_name(player)
		if not player then
			return false
		end
	end

	assert(type(tname) == "string")

	local team = _team_by_name[tname]
	if team then
		player:get_meta():set_string("team", tname)

		for i=1, #_registered_on_team_changed do
			_registered_on_team_changed[i](player, team)
		end

		return true
	else
		return false
	end
end

function teams.get_members(tname)
	local retval = {}

	local players = minetest.get_connected_players()
	for i=1, #players do
		if players[i]:get_meta():get_string("team") == tname then
			retval[#retval + 1] = players[i]
		end
	end

	return retval
end

function teams.chat_send_team(tname, message)
	local players = minetest.get_connected_players()
	for i=1, #players do
		if players[i]:get_meta():get_string("team") == tname then
			minetest.chat_send_player(players[i]:get_player_name(), message)
		end
	end
end

function teams.register_on_team_changed(func)
	_registered_on_team_changed[#_registered_on_team_changed + 1] = func
end

function teams.register_on_points_changed(func)
	_registered_on_points_changed[#_registered_on_points_changed + 1] = func
end

local storage = minetest.get_mod_storage()

function teams.load()
	local json = storage:get("teams")
	if json then
		local list = minetest.parse_json(json)
		for i=1, #list do
			teams.create(list[i])
		end
	else
		teams.create({
			name = "red",
			color = "red",
			color_hex = 0xFF0000,
		})

		teams.create({
			name = "green",
			color = "green",
			color_hex = 0x00FF00,
		})

		teams.create({
			name = "blue",
			color = "blue",
			color_hex = 0x0000FF,
		})

		teams.create({
			name = "yellow",
			color = "yellow",
			color_hex = 0xFF9900,
		})
	end
end

function teams.save()
	local json = minetest.write_json(teams.get_all())
	storage:set_string("teams", json)
end
