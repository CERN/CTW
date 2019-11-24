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

-- Place schematic on mapgen
minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm = minetest.get_mapgen_object("voxelmanip")
	local origin = world.get_location("world_1")
	minetest.place_schematic_on_vmanip(vm, origin, map_path, nil, nil, false)
	vm:write_to_map()
end)

-- Load the entire map
local area = world.get_area("world")
assert(area)
minetest.after(0, function()
	world.emerge_with_callbacks(area.from, area.to, function()
		minetest.fix_light(area.from, area.to)
	end)
end)
