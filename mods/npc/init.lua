-- Basic setup

local modpath = minetest.get_modpath("npc")
npc = {}

dofile(modpath .. "/api.lua")
dofile(modpath .. "/sanity_check.lua")
dofile(modpath .. "/dialogue_tree.lua")

npc.register_npc("steve")