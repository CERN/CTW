teams = {}

dofile(minetest.get_modpath("teams") .. "/api.lua")
dofile(minetest.get_modpath("teams") .. "/chatcmd.lua")
dofile(minetest.get_modpath("teams") .. "/tint.lua")

teams.load()

minetest.register_on_shutdown(function()
	teams.save()
end)
