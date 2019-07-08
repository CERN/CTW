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
local TX_INTERVAL = 3
local MAX_HOP_COUNT = 50

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
-- ######################
dofile(minetest.get_modpath("reseau").."/wires.lua")

-- ######################
-- #     Receivers      #
-- ######################
local receiver_get_formspec = function(meta, throughput, points)
	throughput = reseau.throughput_string(throughput) or 0
	points = reseau.throughput_string(points) or 0
	local throughput_limit = reseau.throughput.get_receiver_throughput_limit()

	return "size[8,5;]"..
		"list[context;tapes;3.5,0;1,1;]"..
		"label[0,1.5;" .. S("The computing center processes and stores experiment data to make discoveries.") .. "]"..
		"label[0,1.9;" .. S("Connect this rack to an experiment or feed it tapes to gain points!") .. "]"..
		"label[0,2.3;" .. S("Current network throughput: @1MB/s, your team gains @2 points/s", throughput, points) .. "]"..
		"label[0,2.7;" .. S("Processing throughput limit: @1MB/s", reseau.throughput_string(throughput_limit)) .. "]"..
		"list[current_player;main;0,4;8,1;]"
end

minetest.register_node("reseau:receiverscreen", {
	description = S("Receiver (Testing)"),
	tiles = {
		"reseau_receiverscreen_top.png",
		"reseau_receiverscreen_bottom.png",
		"reseau_receiverscreen_right.png",
		"reseau_receiverscreen_left.png",
		"reseau_receiverscreen_back.png",
		"reseau_receiverscreen_front.png"
	},
	groups = {},
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5+1/16, -0.5, -6/16, 0.5-1/16, -0.5+2/16, 5/16}, -- base (keyboard)
			{-0.5+1/16, -0.5, 1/16, 0.5-1/16, -0.5+12/16, 5/16}, -- screen
			{-0.5+3/16, -0.5+2/16, 5/16, 0.5-3/16, -0.5+11/16, 7/16} -- screen bump
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5+1/16, -0.5, -6/16, 0.5-1/16, -0.5+2/16, 5/16}, -- base (keyboard)
			{-0.5+1/16, -0.5, 1/16, 0.5-1/16, -0.5+12/16, 5/16}, -- screen
			{-0.5+3/16, -0.5+2/16, 5/16, 0.5-3/16, -0.5+11/16, 7/16} -- screen bump
		}
	},
	reseau = {
		receiver = {
			technology = reseau.technologies.all(),
			rules = {vector.new(0, -1, 0)},
			action = function(pos, packet, depth)
				-- Process packet: throughput to points
				reseau.bitparticles_receiver(pos, depth)
				local throughput_limit = reseau.throughput.get_receiver_throughput_limit()
				local throughput = math.min(throughput_limit, packet.throughput)

				local dp = throughput * TX_INTERVAL * reseau.era.get_current().dp_multiplier
				teams.add_points(packet.team, dp)

				-- Update formspec
				local meta = minetest.get_meta(pos)
				meta:set_string("formspec", receiver_get_formspec(meta, throughput, dp / TX_INTERVAL))

				-- Automatically reset throughput formspec to 0 MB/s after timeout
				local timer = minetest.get_node_timer(pos)
				timer:start(TX_INTERVAL + 1)

				return throughput
			end
		}
	},
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if stack:get_name() == "reseau:tape" then
			local tape_meta = stack:get_meta()
			local capacity = tape_meta:get_int("capacity")
			local team = tape_meta:get_string("team")
			local dp = capacity * reseau.era.get_current().dp_multiplier

			if teams.get(team) then
				teams.add_points(team, dp)
				local chatmsg = S("@1 delivered @2 MB to the computing center, generating @3 discovery points!",
					player:get_player_name(), capacity, dp)
				teams.chat_send_team(team, minetest.colorize("#50ff50", chatmsg))
			end

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:remove_item("tapes", "reseau:tape")
		end
	end,
	-- timer that expires after TX_INTERVAL + 1 is reset whenever packet is received
	-- if no packet is received during that time, reset throughput display to show 0 MB/s
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", receiver_get_formspec(meta, 0, 0))
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("tapes", 1)

		meta:set_string("formspec", receiver_get_formspec(meta))
	end
})

minetest.register_node("reseau:receiverbase", {
	drawtype = "nodebox",
	description = S("Receiver Base"),
	tiles = {
		"reseau_receiverbase_top.png",
		"reseau_receiverbase_bottom.png",
		"reseau_receiverbase_left.png",
		"reseau_receiverbase_right.png",
		"reseau_receiverbase_back.png",
		"reseau_receiverbase_front.png"
	},
	inventory_image = "reseau_receiverbase_inv.png",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 3},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -6/16, 0.5, 0.5, 5/16},
			{-2/16, -.5, 5/16, 2/16, -.5+2/16, 8/16}
		}
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -6/16, 0.5, 0.5, 5/16},
			{-2/16, -.5, 5/16, 2/16, -.5+2/16, 8/16}
		}
	},
	reseau = {
		conductor = {
			infinite_speed = true,
			technology = reseau.technologies.all(),
			rules = function(node)
				--return {minetest.facedir_to_dir(node.param2)}
				return reseau.mergetable(
					{minetest.facedir_to_dir(node.param2)},
					{vector.new(0, 1, 0)}
				)
			end
		}
	},
	after_place_node = function(pos)
		local node = minetest.get_node(pos)
		minetest.set_node(vector.add(pos, vector.new(0, 1, 0)), {
			name = "reseau:receiverscreen",
			param2 = node.param2
		})
	end,
	after_dig_node = function(pos)
		minetest.remove_node(vector.add(pos, vector.new(0, 1, 0)))
	end
})

-- ######################
-- #      Routers       #
-- ######################
local function get_merger_infotext(throughput, throughput_limit)
	return S("Router: Current throughput @1 MB/s, maximum throughput @2 MB/s", reseau.throughput_string(throughput), reseau.throughput_string(throughput_limit))
end

for _, team in ipairs(teams.get_all()) do
	local router_name = "reseau:merger_" .. team.name
	minetest.register_node(router_name, {
		description = S("Router (Merging)"),
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
				technology = reseau.technologies.all(),
				rules = function(node)
					return reseau.mergetable(
						reseau.rotate_rules_left({minetest.facedir_to_dir(node.param2)}),
						reseau.rotate_rules_right({minetest.facedir_to_dir(node.param2)})
					)
				end,
				action = function(pos, packet, depth)
					if packet.hop_count == MAX_HOP_COUNT then
						-- Drop packet accept it but do not do anything
						return packet.throughput
					end

					local meta = minetest.get_meta(pos)
					local cache = meta:get_int("cache") or 0
					local hop_count = meta:get_int("hop_count") or 0
					local cache_limit = reseau.throughput.get_router_throughput_limit(router_name) * TX_INTERVAL
					local available = cache_limit - cache
					local used = math.min(available, packet.throughput * TX_INTERVAL)

					meta:set_int("cache", cache + used)
					meta:set_int("hop_count", math.max(hop_count, packet.hop_count))

					return used / TX_INTERVAL
				end
			},
			transmitter = {
				technology = reseau.technologies.all(),
				rules = function(node)
					return {minetest.facedir_to_dir(node.param2)}
				end,
				autotransmit = {
					interval = TX_INTERVAL,
					action = function(pos)
						local meta = minetest.get_meta(pos)
						local cache = meta:get_int("cache") or 0
						local hop_count = meta:get_int("hop_count") or 0

						local throughput_limit = reseau.throughput.get_router_throughput_limit(router_name)
						local actual_throughput = 0

						if cache > 0 then
							-- try to transmit as much data as possible via network
							local node = minetest.get_node(pos)
							local cablepos = vector.add(pos, minetest.facedir_to_dir(node.param2))
							local attempted_throughput = math.min(cache / TX_INTERVAL, throughput_limit)

							actual_throughput = reseau.transmit(pos, cablepos, {
								throughput = attempted_throughput,
								team = team.name,
								hop_count = hop_count + 1
							})

							cache = cache - actual_throughput * TX_INTERVAL
							assert (cache >= 0)
							meta:set_int("hop_count", 0)
							meta:set_int("cache", cache)
						end

						meta:set_string("infotext", get_merger_infotext(actual_throughput, throughput_limit))
					end
				}
			}
		}
	})
end

local function get_splitter_infotext(throughput, throughput_limit)
	return S("Router: Current throughput @1 MB/s, maximum throughput @2 MB/s", reseau.throughput_string(throughput), reseau.throughput_string(throughput_limit))
end

for _, team in ipairs(teams.get_all()) do
	local router_name = "reseau:splitter_" .. team.name
	minetest.register_node(router_name, {
		description = S("Router (Splitting)"),
		tiles = {
			reseau.with_overlay("reseau_splitter_top.png", team.color, "reseau_splitter_top_overlay.png"),
			"reseau_splitter_bottom.png",
			"reseau_splitter_side_connection.png",
			"reseau_splitter_side_connection.png",
			"reseau_splitter_side_noconnection.png",
			"reseau_splitter_side_connection.png"
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
			{-2/16, -.5, -8/16, 2/16, -.5+2/16, -1/16}, -- z negative
			{-8/16, -.5, -2/16, -1/16, -.5+2/16, 2/16}, -- x negative
			{-3/16, -.5, -5/16, 3/16, -.5+3/16, 5/16},
			{-4/16, -.5, -4/16, 4/16, -.5+3/16, 4/16},
			{-5/16, -.5, -3/16, 5/16, -.5+3/16, 3/16} -- center box
		}},
		team_name = team.name,
		reseau = {
			receiver = {
				technology = reseau.technologies.all(),
				rules = function(node)
					return {vector.multiply(minetest.facedir_to_dir(node.param2), -1)}
				end,
				action = function(pos, packet, depth)
					if packet.hop_count == MAX_HOP_COUNT then
						-- Drop packet accept it but do not do anything
						return packet.throughput
					end

					local meta = minetest.get_meta(pos)
					local cache = meta:get_int("cache") or 0
					local hop_count = meta:get_int("hop_count") or 0
					local cache_limit = reseau.throughput.get_router_throughput_limit(router_name) * TX_INTERVAL
					local available = cache_limit - cache
					local used = math.min(available, packet.throughput * TX_INTERVAL)

					meta:set_int("cache", cache + used)
					meta:set_int("hop_count", math.max(hop_count, packet.hop_count))

					return used / TX_INTERVAL
				end
			},
			transmitter = {
				technology = reseau.technologies.all(),
				rules = function(node)
					return reseau.mergetable(
						reseau.rotate_rules_left({minetest.facedir_to_dir(node.param2)}),
						reseau.rotate_rules_right({minetest.facedir_to_dir(node.param2)})
					)
				end,
				autotransmit = {
					interval = TX_INTERVAL,
					action = function(pos)
						local meta = minetest.get_meta(pos)
						local cache = meta:get_int("cache") or 0
						local hop_count = meta:get_int("hop_count") or 0
						local throughput_limit = reseau.throughput.get_router_throughput_limit(router_name)
						local node = minetest.get_node(pos)

						local rules = reseau.mergetable(
							reseau.rotate_rules_left({minetest.facedir_to_dir(node.param2)}),
							reseau.rotate_rules_right({minetest.facedir_to_dir(node.param2)})
						)

						-- first try to output all cached data through left output,
						-- then transmit what is left over through right output
						local actual_throughput = 0
						for _, dir in ipairs(rules) do
							if cache > 0 then
								local cablepos = vector.add(pos, dir)
								local attempted_throughput = math.min(throughput_limit, cache / TX_INTERVAL)
								local packet_throughput = reseau.transmit(pos, cablepos, {
									throughput = attempted_throughput,
									team = team.name,
									hop_count = hop_count + 1
								})

								cache = cache - packet_throughput * TX_INTERVAL
								actual_throughput = actual_throughput + packet_throughput
								assert (cache >= 0)
							end
						end

						meta:set_int("hop_count", 0)
						meta:set_int("cache", cache)
						meta:set_string("infotext", get_splitter_infotext(actual_throughput, throughput_limit))
					end
				}
			}
		}
	})
end

-- ######################
-- #    Experiments     #
-- ######################
minetest.register_entity("reseau:atom", {
	initial_properties = {
		visual = "mesh",
		visual_size = {x=0.4, y=0.4},
		mesh = "reseau_atom_ts.obj",
		textures = {
			"reseau_atom_core.png",
			"reseau_atom_electron.png",
			"reseau_atom_ring.png"
		},
		automatic_rotate = 1,
		collisionbox = {},
		selectionbox = {},
		glow = 10
	}
})

local experiment_get_formspec = function(experiment_name, meta, throughput)
	throughput = reseau.throughput_string(throughput) or 0
	local cache = meta:get_int("cache")
	local throughput_limit = reseau.throughput_string(reseau.throughput.get_experiment_throughput(experiment_name))

	return "size[8,5;]"..
		"list[context;tapes;2,0;4,1;]"..
		"label[0,1.5;" .. S("Experiments generate data that has to be moved to the computing center.") .. "]"..
		"label[0,1.9;" .. S("Data can be transported manually by carrying tapes or by a network link.") .. "]"..
		"label[0,2.3;" .. S("Data generation speed: @1 MB/s", throughput_limit) .. "]"..
		"label[0,2.7;" ..
		S("Cached data: @1 MB / Tape capacity: @2 MB", cache, reseau.era.get_current().tape_capacity) .. "]"..
		"label[0,3.1;" .. S("Network throughput: @1 MB/s", throughput) .. "]"..
		"list[current_player;main;0,4;8,1;]"
end

for _, team in ipairs(teams.get_all()) do
	local experiment_name = "reseau:experiment_" .. team.name
	minetest.register_node(experiment_name, {
		description = S("Experiment"),
		groups = { ["protection_" .. team.name] = 1 },
		team_name = team.name,
		light_source = 10,
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = {
			reseau.with_overlay("reseau_experiment_top.png", team.color, "reseau_experiment_top_overlay.png"),
			reseau.with_overlay("reseau_experiment_bottom_overlay.png", team.color, "reseau_experiment_bottom_overlay.png"),
			reseau.with_overlay("reseau_experiment_side_connection.png", team.color,
				"reseau_experiment_side_connection_overlay.png"),
			reseau.with_overlay("reseau_experiment_side.png", team.color, "reseau_experiment_side_overlay.png"),
			reseau.with_overlay("reseau_experiment_right.png", team.color, "reseau_experiment_side_overlay.png"),
			reseau.with_overlay("reseau_experiment_left.png", team.color, "reseau_experiment_side_overlay.png")
		},
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-6/16, -.5, -6/16, 6/16, -.5+8/16, 6/16},
				{-4/16, -.5, -4/16, 4/16, -.5+10/16, 4/16},
				{1/16, -.5, -2/16, 8/16, -.5+2/16, 2/16}
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-6/16, -.5, -6/16, 6/16, -.5+8/16, 6/16},
				{-4/16, -.5, -4/16, 4/16, -.5+10/16, 4/16},
				{1/16, -.5, -2/16, 8/16, -.5+2/16, 2/16}
			}
		},
		on_construct = function(pos)
			minetest.add_entity(vector.add(pos, vector.new(0, 0.5, 0)), "reseau:atom")

			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:set_size("tapes", 4)

			meta:set_string("formspec", experiment_get_formspec(experiment_name, meta))
		end,
		on_destruct = function(pos)
			local objs = minetest.get_objects_inside_radius(pos, 1.0)
			for _, obj in ipairs(objs) do
				local entity = obj:get_luaentity()
				if entity and entity.name == "reseau:atom" then
					obj:remove()
				end
			end
		end,
		reseau = {
			transmitter = {
				technology = reseau.technologies.all(),
				rules = function(node)
					return reseau.rotate_rules_left({minetest.facedir_to_dir(node.param2)})
				end,
				autotransmit = {
					interval = TX_INTERVAL,
					action = function(pos)
						-- generate data to transmit
						local meta = minetest.get_meta(pos)
						local cache = meta:get_int("cache") or 0
						cache = cache + reseau.throughput.get_experiment_throughput(experiment_name) * TX_INTERVAL

						-- try to transmit as much data as possible via network
						local throughput = reseau.transmit_first(pos, {
							throughput = cache / TX_INTERVAL,
							team = team.name,
							hop_count = 0
						})

						-- if there is enough cached data to put on a tape, just
						-- write a tape
						cache = cache - throughput * TX_INTERVAL
						local tape_capacity = reseau.era.get_current().tape_capacity
						if cache > tape_capacity then
							cache = cache - reseau.era.get_current().tape_capacity

							local inv = meta:get_inventory()
							local tape_stack = ItemStack("reseau:tape 1")
							local tape_meta = tape_stack:get_meta()
							tape_meta:set_int("capacity", tape_capacity)
							tape_meta:set_string("team", team.name)
							local desc = S("@1 MB tape (@2)", tape_capacity, team.display_name)
							tape_meta:set_string("description", desc)

							if inv:room_for_item("tapes", tape_stack) then
								inv:add_item("tapes", tape_stack)
							else
								cache = tape_capacity
							end
						end

						-- update node metadata
						meta:set_int("cache", cache)
						meta:set_string("formspec", experiment_get_formspec(experiment_name, meta, throughput))
					end
				}
			}
		}
	})
end

-- ######################
-- #        Tape        #
-- ######################
minetest.register_craftitem("reseau:tape", {
	image = "reseau_tape.png",
	stack_max = 1,
	description= S("Data Tape")
})
