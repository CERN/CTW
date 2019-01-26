print("Found the GameJam CERN Craft The Web mod! Yay!")

local ret = dofile(minetest.get_modpath("gjcctw") .. "/script.lua")
print(ret)

minetest.register_node("gjcctw:reference", {
    description = "This is a reference node",
    tiles = {"reference_16x16.png"},
    groups = {cracky=1, oddly_breakable_by_hand=2}
})

minetest.register_node("gjcctw:idea", {
    description = "This is an idea node",
    tiles = {"idea_16x16.png"},
    groups = {cracky=1, oddly_breakable_by_hand=2}
})

minetest.register_node("gjcctw:paper", {
    description = "This is a paper node",
    tiles = {"paper_16x16.png"},
    groups = {cracky=1, oddly_breakable_by_hand=2}
})
