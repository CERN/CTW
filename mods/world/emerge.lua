if minetest.get_mapgen_setting("mg_name") ~= "singlenode" then
	minetest.log("error", "Prebuilt map is disabled when not running singlenode!")
	return
end

local map_path = minetest.get_modpath("world") .. "/schematics/world.mts"
local conf_path = minetest.get_modpath("world") .. "/schematics/world.conf"
if not file_exists(map_path) then
	minetest.log("error", "Prebuilt map not found. Please create a schematic at " .. map_path)
	return
end

if not file_exists(conf_path) then
	minetest.log("error", "Location configuration for map not found. Please create one at " .. conf_path)
	return
end

world.load_locations(conf_path)

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

local function emerge_with_callbacks(pos1, pos2, callback)
	local context = {
		current_blocks = 0,
		total_blocks   = 0,
		start_time     = os.clock(),
		callback       = callback,
	}

	minetest.emerge_area(pos1, pos2, emergeblocks_callback, context)
end

-- Place schematic on mapgen
minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm = minetest.get_mapgen_object("voxelmanip")
	minetest.place_schematic_on_vmanip(vm, { x = 0, y = 0, z = 0 }, map_path)
	vm:write_to_map()
end)

-- Load the entire map
local area = world.get_area("world")
assert(area)
minetest.after(0, function()
	emerge_with_callbacks(area.from, area.to, function()
		minetest.fix_light(area.from, area.to)
	end)
end)
