reseau = {}

dofile(minetest.get_modpath("reseau").."/util.lua")
dofile(minetest.get_modpath("reseau").."/technology.lua")
dofile(minetest.get_modpath("reseau").."/rules.lua")
dofile(minetest.get_modpath("reseau").."/wires.lua")
dofile(minetest.get_modpath("reseau").."/particles.lua")
dofile(minetest.get_modpath("reseau").."/transmit.lua")
dofile(minetest.get_modpath("reseau").."/modstorage.lua")
dofile(minetest.get_modpath("reseau").."/transmittermgmt.lua")

minetest.register_node(":reseau:testtransmitter", {
	description = "Transmitter (Testing)",
	tiles = {"default_tree.png"},
	groups = {cracky = 3},
	reseau = {
		transmitter = {
			technology = {
				"copper", "fiber"
			},
			rules = reseau.rules.default,
			autotransmit = {
				interval = 3,
				action = function(pos)
					reseau.transmit_first(pos, "hello world!")
				end
			}
		}
	},
})

local receiveCount = 0
local receiveCountHud = nil
minetest.register_node(":reseau:testreceiver", {
	description = "Receiver (Testing)",
	tiles = {"default_water.png"},
	groups = {cracky = 3},
	reseau = {
		receiver = {
			technology = {
				"copper", "fiber"
			},
			rules = reseau.rules.default,
			action = function(pos, content)
				print("RECEIVED: "..dump(content))
				receiveCount = receiveCount + 1
				local player = minetest.get_player_by_name("singleplayer")
				local hudtext = "Received: " .. receiveCount

				if receiveCountHud ~= nil then
					player:hud_change(idx, "text", hudtext)
				else
					receiveCountHud = player:hud_add({
						hud_elem_type = "text",
						position = {x = 1.0, y = 0.0},
						offset = {x = -100, y = 20},
						text = hudtext,
						alignment = {x = 0, y = 0},
						scale = {x = 100, y = 100}
					})
				end
			end
		}
	},
})

local ROUTER_DELAY = 3
minetest.register_node(":reseau:testrouter", {
	description = "Router (Testing)",
	tiles = {
		"reseau_router_top.png",
		"reseau_router_bottom.png",
		"reseau_router_side_connection.png",
		"reseau_router_side_connection.png",
		"reseau_router_side_connection.png",
		"reseau_router_side_noconnection.png"
	 },
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 3},
	selection_box = {
		type = "fixed",
		fixed = {-.5, -.5, -.5, .5, -.5+5/16, .5}
	},
	node_box = {type = "fixed", fixed = {
		{1/16, -.5, -2/16, 8/16, -.5+2/16, 2/16}, -- x positive
		{-2/16, -.5, 1/16, 2/16, -.5+2/16, 8/16}, -- z positive
		{-8/16, -.5, -2/16, -1/16, -.5+2/16, 2/16}, -- x negative

		{-3/16, -.5, -5/16, 3/16, -.5+3/16, 5/16},
		{-4/16, -.5, -4/16, 4/16, -.5+3/16, 4/16},
		{-5/16, -.5, -3/16, 5/16, -.5+3/16, 3/16} -- center box
	}},
	reseau = {
		receiver = {
			technology = {
				"copper", "fiber"
			},
			rules = function(node)
				return reseau.mergetable(
					reseau.rotate_rules_left({minetest.facedir_to_dir(node.param2)}),
					reseau.rotate_rules_right({minetest.facedir_to_dir(node.param2)})
				)
			end,
			action = function(pos, message, depth)
				local node = minetest.get_node(pos)
				local cablepos = vector.add(pos, minetest.facedir_to_dir(node.param2))
				reseau.transmit(pos, cablepos, message, depth + ROUTER_DELAY)
			end
		},
		transmitter = {
			technology = {
				"copper", "fiber"
			},
			rules = function(node)
				return {minetest.facedir_to_dir(node.param2)}
			end
		}
	}
})
