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
		file:write(("%s = %d,%d,%d\n"):format(key, pos.x, pos.y, pos.z))
	end
	file:close()
end

-- API to do emerging
local function emergeblocks_callback(pos, action, num_calls_remaining, ctx)
	if ctx.total_blocks == 0 then
		ctx.total_blocks   = num_calls_remaining + 1
		ctx.current_blocks = 0
	end
	ctx.current_blocks = ctx.current_blocks + 1

	if ctx.current_blocks == ctx.total_blocks then
		ctx:callback()
	end
end

function world.emerge_with_callbacks(pos1, pos2, callback)
	local context = {
		current_blocks = 0,
		total_blocks   = 0,
		start_time     = os.clock(),
		callback       = callback,
	}

	minetest.emerge_area(pos1, pos2, emergeblocks_callback, context)
end
