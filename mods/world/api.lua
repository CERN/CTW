local _locations = {}
local _team_locations = {}

function world.get_location(name)
	return _locations[name]
end

function world.get_team_location(tname, name)
	local teaml = _team_locations[tname] or {}
	return teaml[name]
end

function world.get_area(name)
	return {
		from = world.get_location(name .. "_1"),
		to = world.get_location(name .. "_2")
	}
end

function world.get_team_area(tname, name)
	return {
		from = world.get_team_location(tname, name .. "_1"),
		to = world.get_team_location(tname, name .. "_2")
	}
end

function world.load_locations(path)
	local locs = Settings(path):to_table()
	print(dump(locs))
	for key, value in pairs(locs) do
		local pos = minetest.string_to_pos(value)

		local tname, name = key:match("(%w+)%.(%w+)")
		if tname then
			_team_locations[tname] = _team_locations[tname] or {}
			_team_locations[tname][name] = pos
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
