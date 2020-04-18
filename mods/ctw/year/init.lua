year = {}

dofile(minetest.get_modpath("year") .. "/api.lua")

local pb = progressbar.ProgressBar:new()
pb.width = 600
pb.offset = { x = 0, y = 20 }
pb.min, pb.max = year.get_range()

local function set_values()
	local ret = {}
	for tname, team in pairs(teams.get_dict()) do
		ret[tname] = team.year or pb.min
	end

	pb:set_values(ret)
end

year.register_on_change(set_values)

if minetest.global_exists("ctw_technologies") then
	ctw_technologies.register_on_gain(function(tech, team)
		if tech.year then
			year.bump(tech.year, team.name)
		end
	end)
end

minetest.register_on_joinplayer(function(player)
	pb:update_hud_for_player(player)
end)

teams.register_on_team_changed(function(player)
	pb:update_hud_for_player(player)
end)

set_values()


-- For testing
--
-- local list = teams.get_all()
-- for i=1, #list do
-- 	local team = list[i]
-- 	team.year = math.random(pb.min*10, 10*(pb.max + pb.min) / 2)/10
-- 	print(team.year)
-- 	year.bump(team.year, team.name)
-- end

minetest.register_chatcommand("year", {
	params = "<year>",
	description = "Set year for your team (debug)",
	func = function(playername, v)
		local v_number = tonumber(v)
		if type(v_number) == "number" then
			year.set(v_number, teams.get_by_player(playername))
			return true
		else
			return false, "Invalid year"
		end
	end,
})
