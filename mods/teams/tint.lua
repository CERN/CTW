local hud = hudkit()

local function set_tint(player, team)
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

minetest.register_on_joinplayer(function(player)
	local team = teams.get_by_player(player)
	set_tint(player, team)
end)

teams.register_on_change_team(set_tint)
