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
					reseau.transmit(pos, "hello world!")
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
			receive = function(pos, content)
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

