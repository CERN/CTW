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
