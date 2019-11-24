local S = minetest.get_translator("teams")

teams = {}

dofile(minetest.get_modpath("teams") .. "/api.lua")
dofile(minetest.get_modpath("teams") .. "/chatcmd.lua")

teams.load()
dofile(minetest.get_modpath("teams") .. "/hand.lua")

local function safe_recursive()
	teams.save()
	minetest.after(20, safe_recursive)
end
minetest.after(20, safe_recursive)

minetest.register_on_shutdown(teams.save)


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
			text          = team.display_name_capitalized,
			number        = team.color_hex,
			offset        = {x = -20, y = 20},
			alignment     = {x = -1, y = 0}
		})
	else
		hud:change(player, "teams:hud_team", "text", team.display_name_capitalized)
		hud:change(player, "teams:hud_team", "number", team.color_hex)
	end

	player_api.set_textures(player, { "team_skin_" .. team.name .. ".png" })
end

local pb = progressbar.ProgressBar:new()
pb.width = 600
pb.offset = { x = 0, y = 70 }
pb.min, pb.max = 0, 6000000

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
			number        = 0xFFFFFF,
			offset        = {x = -20, y = 40},
			alignment     = {x = -1, y = 0}
		})
	else
		hud:change(player, "teams:hud_dp", "text", S("DP @1", team.points))
		-- hud:change(player, "teams:hud_dp", "number", team.color_hex)
	end
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
		hud:change(player, "teams:hud_wp", "text", S("DP @1", team.points))
		hud:change(player, "teams:hud_wp", "number", team.color_hex)
		hud:change(player, "teams:hud_wp", "world_pos", pos)
	end
end

local function rebuild_dps_bar()
	local dps = {}
	for tname, team2 in pairs(teams.get_dict()) do
		dps[tname] = team2.points or 0
	end
	pb:set_values(dps)
end

rebuild_dps_bar()

local function on_team_change(player, team)
	set_tint(player, team)
	set_dp(player, team)
	set_waypoint(player, team)
	rebuild_dps_bar()
end

minetest.register_on_joinplayer(function(player)
	local team = teams.get_by_player(player)
	on_team_change(player, team)
	pb:update_hud_for_player(player)
end)

teams.register_on_team_changed(on_team_change)

teams.register_on_points_changed(function(team, _)
	for _, player in pairs(teams.get_online_members(team.name)) do
		set_dp(player, team)
	end
end)
