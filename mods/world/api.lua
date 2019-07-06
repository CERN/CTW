local _locations = {}
local _team_locations = {}

function world.get_location(name)
	return _locations[name]
end

function world.get_team_location(tname, name)
	return _team_locations[tname][name]
end

function world.load_locations(path)
	local locs = Settings(path):to_table()
	for key, value in pairs(locs) do
		local pos = minetest.str_to_pos(value)

		local tname, name = key:match("(%w+)%.(%w+)")
		if tname then
			_locations[tname][name] = pos
		else
			_locations[key] = pos
		end
	end
end

function world.place(map)
	world.emerge_with_callbacks(nil, map.pos1, map.pos2, function()
		local schempath = map.schematic

		local res = minetest.place_schematic(map.pos1, schempath)
		assert(res)

		minetest.after(10, function()
			minetest.fix_light(map.pos1, map.pos2)
		end)
	end, nil)
end
