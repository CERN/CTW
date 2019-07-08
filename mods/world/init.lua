world = {}

dofile(minetest.get_modpath("world") .. "/api.lua")
dofile(minetest.get_modpath("world") .. "/sounds.lua")

if minetest.get_modpath("teams") then
	dofile(minetest.get_modpath("world") .. "/emerge.lua")
else
	minetest.chat_send_all("** WORLD BUILDER MODE **")
end
