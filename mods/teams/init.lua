teams = {}

dofile(minetest.get_modpath("teams") .. "/api.lua")
dofile(minetest.get_modpath("teams") .. "/chatcmd.lua")

teams.load()

minetest.register_on_shutdown(function()
	teams.save()
end)


local hud = hudkit()

local function set_tint(player, team)
	if not team then
		hud:remove(player, "teams:hud_team")
		return
	end

	if not hud:exists(player, "teams:hud_team") then
		hud:add(player, "teams:hud_team", {
			hud_elem_type = "text",
			position      = {x = 1, y = 0},
			scale         = {x = 100, y = 100},
			text          = "Team " .. team.name,
			number        = team.color_hex,
			offset        = {x = -20, y = 20},
			alignment     = {x = -1, y = 0}
		})
	else
		hud:change(player, "teams:hud_team", "text", "Team " .. team.name)
		hud:change(player, "teams:hud_team", "number", team.color_hex)
	end

	player_api.set_textures(player, { "team_skin_" .. team.name .. ".png" })
end

local function set_dp(player, team)
	if not team then
		hud:remove(player, "teams:hud_dp")
		return
	end

	if not hud:exists(player, "teams:hud_dp") then
		hud:add(player, "teams:hud_dp", {
			hud_elem_type = "text",
			position      = {x = 1, y = 0},
			scale         = {x = 100, y = 100},
			text          = "DP: " .. team.points,
			-- number        = team.color_hex,
			offset        = {x = -20, y = 40},
			alignment     = {x = -1, y = 0}
		})
	else
		hud:change(player, "teams:hud_dp", "text", "DP " .. team.points)
		-- hud:change(player, "teams:hud_dp", "number", team.color_hex)
	end

	player_api.set_textures(player, { "team_skin_" .. team.name .. ".png" })
end

local function set_waypoint(player, team)
	if not team then
		hud:remove(player, "teams:hud_wp")
		return
	end

	local pos = world.get_team_location(team.name, "base")
	if not pos then
		hud:remove(player, "teams:hud_wp")
		return
	end

	if not hud:exists(player, "teams:hud_wp") then
		hud:add(player, "teams:hud_wp", {
			hud_elem_type = "waypoint",
			name          = "Base",
			text          = "m",
			number        = team.color_hex,
			world_pos     = pos,
		})
	else
		hud:change(player, "teams:hud_wp", "text", "DP " .. team.points)
		hud:change(player, "teams:hud_wp", "number", team.color_hex)
		hud:change(player, "teams:hud_wp", "world_pos", pos)
	end
end

local function on_team_change(player, team)
	set_tint(player, team)
	set_dp(player, team)
	set_waypoint(player, team)
end

minetest.register_on_joinplayer(function(player)
	local team = teams.get_by_player(player)
	on_team_change(player, team)
end)

teams.register_on_team_changed(on_team_change)

teams.register_on_points_changed(function(team, _)
	for _, player in pairs(minetest.get_connected_players()) do
		set_dp(player, team)
	end
end)
