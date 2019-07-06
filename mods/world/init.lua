world = {}

dofile(minetest.get_modpath("world") .. "/emerge.lua")
dofile(minetest.get_modpath("world") .. "/api.lua")
dofile(minetest.get_modpath("world") .. "/sounds.lua")

if minetest.get_modpath("teams") == nil then
	minetest.chat_send_all("** WORLD BUILDER MODE **")
	return
end

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

world.load_locations(conf_path)

minetest.after(0, function()
	world.place({
		pos1 = vector.new(0, 0, 0),
		pos2 = vector.new(0, 0, 0),
		schematic = map_path,
	})
end)
