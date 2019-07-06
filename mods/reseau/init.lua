reseau = {}

reseau.era = {}
reseau.era.genspeed = 10 -- experiment data generation speed in MB/s
reseau.era.tape_capacity = 500 -- tape capacity in MB
reseau.era.dp_multiplier = 1 -- discovery points per delivered MB

dofile(minetest.get_modpath("reseau").."/util.lua")
dofile(minetest.get_modpath("reseau").."/technology.lua")
dofile(minetest.get_modpath("reseau").."/rules.lua")
dofile(minetest.get_modpath("reseau").."/wires.lua")
dofile(minetest.get_modpath("reseau").."/particles.lua")
dofile(minetest.get_modpath("reseau").."/transmit.lua")
dofile(minetest.get_modpath("reseau").."/modstorage.lua")
dofile(minetest.get_modpath("reseau").."/transmittermgmt.lua")


local TX_INTERVAL = 3
local transmitter_get_formspec = function(meta)
	local cache = meta:get_int("cache")

	return "size[8,5;]"..
		"list[context;tapes;2,0;4,1;]"..
		"label[0,1.5;Experiments generate data that has to be moved to the computing center.]"..
		"label[0,1.9;Data can be transported manually by carrying tapes or by a network link.]"..
		"label[0,2.3;Data generation speed: "..reseau.era.genspeed.." MB/s]"..
		"label[0,2.7;Cached data: "..cache.." MB / Tape capacity: "..reseau.era.tape_capacity.." MB]"..
		"list[current_player;main;0,4;8,1;]"
end

-- TODO: team ownership (save in tape meta)!
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
					-- try to transmit data via network, otherwise store on tape
					if (not reseau.transmit_first(pos, "hello world!")) then
						local meta = minetest.get_meta(pos)
						local cache = meta:get_int("cache") or 0

						cache = cache + reseau.era.genspeed * TX_INTERVAL
						if cache > reseau.era.tape_capacity then
							cache = cache - reseau.era.tape_capacity

							local inv = meta:get_inventory()
							local tape_stack = ItemStack("reseau:tape 1")
							local tape_meta = tape_stack:get_meta()
							tape_meta:set_int("capacity", reseau.era.tape_capacity)
							tape_meta:set_string("team", "red")
							tape_meta:set_string("description", reseau.era.tape_capacity.." MB tape (team red)")

							inv:add_item("tapes", tape_stack)
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
		inv:set_size("tapes", 4)

		meta:set_string("formspec", transmitter_get_formspec(meta))
	end
})

local receiver_get_formspec = function(meta)
	return "size[8,5;]"..
		"list[context;tapes;3.5,0;1,1;]"..
		"label[0,1.5;The computing center processes and stores experiment data to make discoveries.]"..
		"label[0,1.9;Place tapes here to gain discovery points!]"..
		"list[current_player;main;0,4;8,1;]"
end

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
			end
		}
	},
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if stack:get_name() == "reseau:tape" then
			local tape_meta = stack:get_meta()
			local capacity = tape_meta:get_int("capacity")
			local team = tape_meta:get_string("team")
			local dp = capacity * reseau.era.dp_multiplier

			if teams.get(team) then
				teams.add_points(team, dp)
				local chatmsg = player:get_player_name() .. " delivered "..capacity..
					" MB to the computing center, generating "..dp.." discovery points!"
				teams.chat_send_team(team, minetest.colorize("#50ff50", chatmsg))
			end

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:remove_item("tapes", "reseau:tape")
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("tapes", 1)

		meta:set_string("formspec", receiver_get_formspec(meta))
	end
})

local ROUTER_DELAY = 3
for _, team in ipairs(teams.get_all()) do
	minetest.register_node(":reseau:testrouter_" .. team.name, {
		description = "Router (Testing)",
		tiles = {
			reseau.with_overlay("reseau_router_top.png", team.color, "reseau_router_top_overlay.png"),
			"reseau_router_bottom.png",
			"reseau_router_side_connection.png",
			"reseau_router_side_connection.png",
			"reseau_router_side_connection.png",
			"reseau_router_side_noconnection.png"
		},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = { ["protection_" .. team.name] = 1 },
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
		team_name = team.name,
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
end

minetest.register_craftitem(":reseau:tape", {
	image = "reseau_tape.png",
	stack_max = 1,
	description="Data Tape"
})
