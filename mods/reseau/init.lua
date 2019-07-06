reseau = {}

reseau.era_speed = 10

dofile(minetest.get_modpath("reseau").."/util.lua")
dofile(minetest.get_modpath("reseau").."/technology.lua")
dofile(minetest.get_modpath("reseau").."/rules.lua")
dofile(minetest.get_modpath("reseau").."/wires.lua")
dofile(minetest.get_modpath("reseau").."/particles.lua")
dofile(minetest.get_modpath("reseau").."/transmit.lua")
dofile(minetest.get_modpath("reseau").."/modstorage.lua")
dofile(minetest.get_modpath("reseau").."/transmittermgmt.lua")

local transmitter_get_formspec = function(meta)
	local cache = meta:get_int("cache")

	return "size[8,5;]"..
		"list[context;tapes;3.5,0;8,4;]"..
		"label[0,1.5;Experiments generate tapes, transport them to the computing center]"..
		"label[0,1.9;Data generation speed: "..reseau.era_speed.." MB/s]"..
		"label[0,2.3;Cached data: "..cache.." MB]"..
		"list[current_player;main;0,4;8,1;]"
end

local TX_INTERVAL = 3
local TAPE_CAPACITY = 10
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
				interval = TX_INTERVAL,
				action = function(pos)
					local meta = minetest.get_meta(pos)
					local inv = meta:get_inventory()
					if (not reseau.transmit_first(pos, "hello world!")) then
						local cache = meta:get_int("cache") or 0

						cache = cache + reseau.era_speed / TX_INTERVAL
						if cache > TAPE_CAPACITY then
							cache = cache - TAPE_CAPACITY
							inv:add_item("tapes", "reseau:tape")
						end
						meta:set_int("cache", cache)

						meta:set_string("formspec", transmitter_get_formspec(meta))
					end
				end
			}
		}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("tapes", 1)

		meta:set_string("formspec", transmitter_get_formspec(meta))
	end
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
				receiveCount = receiveCount + 1
				local player = minetest.get_player_by_name("singleplayer")
				local hudtext = "Received: " .. receiveCount

				if receiveCountHud ~= nil then
					player:hud_change(receiveCountHud, "text", hudtext)
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

minetest.register_craftitem(":reseau:tape", {
	image = "reseau_tape.png",
	stack_max = 4,
    	description="Data Tape"
})
