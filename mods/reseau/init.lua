reseau = {}
local S = minetest.get_translator("reseau")

dofile(minetest.get_modpath("reseau").."/util.lua")
dofile(minetest.get_modpath("reseau").."/technology.lua")
dofile(minetest.get_modpath("reseau").."/rules.lua")
dofile(minetest.get_modpath("reseau").."/particles.lua")
dofile(minetest.get_modpath("reseau").."/transmit.lua")
dofile(minetest.get_modpath("reseau").."/modstorage.lua")
dofile(minetest.get_modpath("reseau").."/transmittermgmt.lua")
dofile(minetest.get_modpath("reseau").."/era.lua")
dofile(minetest.get_modpath("reseau").."/throughput.lua")

-- ######################
-- #      Defines       #
-- ######################
reseau.TX_INTERVAL = 3
reseau.MAX_HOP_COUNT = 50

-- TODO: Define reasonable values for eras!
-- TODO: Throughput values: round to one decimal

-- ######################
-- #       Eras         #
-- ######################
reseau.era.register(true, 1986, {
	name = "internet stone age",
	tape_capacity = 500,
	dp_multiplier = 1,
	experiment_throughput_limit = 10,
	router_throughput_limit = 40,
	receiver_throughput_limit = 20
})

reseau.era.register(1986, 1990, {
	name = "after-chernobyl",
	tape_capacity = 500,
	dp_multiplier = 1,
	experiment_throughput_limit = 10,
	router_throughput_limit = 20,
	receiver_throughput_limit = 50
})

reseau.era.register(1990, 1994, {
	name = "early nineties",
	tape_capacity = 500,
	dp_multiplier = 1,
	experiment_throughput_limit = 10,
	router_throughput_limit = 20,
	receiver_throughput_limit = 100
})

reseau.era.register(1994, true, {
	name = "late nineties",
	tape_capacity = 500,
	dp_multiplier = 1,
	experiment_throughput_limit = 10,
	router_throughput_limit = 20,
	receiver_throughput_limit = 1000
})

-- ######################
-- #   Technologies     #
-- ######################
reseau.technologies.register("copper", {
	name = "Telephone (Copper)",
	wire_texture = "reseau_copper_wire.png",
	wire_inventory_image = "reseau_copper_wire_inv.png",
	throughput = 10
})

reseau.technologies.register("ethernet", {
	name = "Ethernet",
	wire_texture = "reseau_ethernet_wire.png",
	wire_inventory_image = "reseau_ethernet_wire_inv.png",
	throughput = 100
})

reseau.technologies.register("fiber", {
	name = "Fiber",
	wire_texture = "reseau_fiber_wire.png",
	wire_inventory_image = "reseau_fiber_wire_inv.png",
	throughput = 10000
})

-- ######################
-- #       Wires        #
-- #     Receivers      #
-- #      Routers       #
-- #    Experiments     #
-- ######################
dofile(minetest.get_modpath("reseau").."/wires.lua")
dofile(minetest.get_modpath("reseau").."/receivers.lua")
dofile(minetest.get_modpath("reseau").."/routers.lua")
dofile(minetest.get_modpath("reseau").."/experiments.lua")

-- ######################
-- #        Tape        #
-- ######################
minetest.register_craftitem("reseau:tape", {
	image = "reseau_tape.png",
	stack_max = 1,
	description= S("Data Tape")
})
