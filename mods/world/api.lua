local _locations = {}

function world.get_location(name)
	return _locations[name]
end

function world.get_all_locations()
	return _locations
end

function world.set_location(name, pos)
	_locations[name] = pos
end

function world.get_team_location(tname, name)
	return _locations[tname .. "." .. name]
end

function world.set_team_location(tname, name, pos)
	_locations[tname .. "." .. name] = pos
end

function world.get_area(name)
	local from = world.get_location(name .. "_1")
	local to = world.get_location(name .. "_2")
	if from and to then
		return { from = from, to = to }
	else
		return nil
	end
end

function world.get_team_area(tname, name)
	return {
		from = world.get_team_location(tname, name .. "_1"),
		to = world.get_team_location(tname, name .. "_2")
	}
end

function world.load_locations(path)
	local locs = Settings(path):to_table()
	for key, value in pairs(locs) do
		_locations[key] = minetest.string_to_pos(value)	
	end
end

function world.save_locations(path)
	local file = io.open(path, "w")
	for key, pos in pairs(_locations) do
		file:write(("%s = %s\n"):format(key, minetest.pos_to_string(pos)))
	end
	file:close()
end
