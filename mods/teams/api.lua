local S = minetest.get_translator("teams")

local _team_by_name = {}
local _tname_by_player = {}
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

function teams.get_all()
	local list = {}
	for _, team in pairs(_team_by_name) do
		list[#list + 1] = team
	end
	return list
end

function teams.get_dict()
	return _team_by_name
end

function teams.create(def)
	assert(type(def) == "table")
	assert(type(def.name) == "string", "Team needs a name!")
	assert(def.name == string.lower(def.name), "Team name must be lowercase!")
	assert(not _team_by_name[def.name], "Team already exists")

	_team_by_name[def.name] = def
	def.points = def.points or 0
	def.display_name = def.display_name or S("team " .. def.name)
	def.display_name_capitalized = def.display_name_capitalized or S("Team " .. def.name)

	return def
end

function teams.get_by_player(name)
	if type(name) ~= "string" then
		name = name:get_player_name()
	end

	local tname = _tname_by_player[name]
	return _team_by_name[tname]
end

function teams.set_team(name, tname)
	local player
	if type(name) == "string" then
		player = minetest.get_player_by_name(name)
	else
		player = name
		name   = player:get_player_name()
	end

	assert(type(tname) == "string")

	local team = _team_by_name[tname]
	if team then
		_tname_by_player[name] = tname

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
	for name, tname2 in pairs(_tname_by_player) do
		if tname == tname2 then
			retval[#retval + 1] = name
		end
	end

	return retval
end

function teams.get_online_members(tname)
	local retval = {}

	local players = minetest.get_connected_players()
	for i=1, #players do
		local name = players[i]:get_player_name()
		if _tname_by_player[name] == tname then
			retval[#retval + 1] = players[i]
		end
	end

	return retval
end

function teams.chat_send_team(tname, message)
	for name, tname2 in pairs(_tname_by_player) do
		if tname == tname2 then
			minetest.chat_send_player(name, message)
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
		local list = minetest.parse_json(json) or {}
		for i=1, #list do
			teams.create(list[i])
		end
	else
		teams.create({
			name = "red",
			display_name = S("team red"),
			display_name_capitalized = S("Team red"),
			color = "red",
			color_hex = 0xFF0000,
		})

		teams.create({
			name = "green",
			display_name = S("team green"),
			display_name_capitalized = S("Team green"),
			color = "green",
			color_hex = 0x00FF00,
		})

		teams.create({
			name = "blue",
			display_name = S("team blue"),
			display_name_capitalized = S("Team blue"),
			color = "blue",
			color_hex = 0x0000FF,
		})

		teams.create({
			name = "yellow",
			display_name = S("team yellow"),
			display_name_capitalized = S("Team yellow"),
			color = "yellow",
			color_hex = 0xFF9900,
		})
	end

	local json2 = storage:get("teamalloc")
	if json2 then
		_tname_by_player = minetest.parse_json(json2) or {}
	end
end

function teams.save()
	storage:set_string("teams", minetest.write_json(teams.get_all()))
	storage:set_string("teamalloc", minetest.write_json(_tname_by_player))
end
