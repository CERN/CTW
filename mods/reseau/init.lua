reseau = {}

dofile(minetest.get_modpath("reseau").."/util.lua")
dofile(minetest.get_modpath("reseau").."/technology.lua")
dofile(minetest.get_modpath("reseau").."/rules.lua")
dofile(minetest.get_modpath("reseau").."/particles.lua")
dofile(minetest.get_modpath("reseau").."/transmit.lua")
dofile(minetest.get_modpath("reseau").."/modstorage.lua")
dofile(minetest.get_modpath("reseau").."/transmittermgmt.lua")
dofile(minetest.get_modpath("reseau").."/era.lua")

-- ######################
-- #      Defines       #
-- ######################
local TX_INTERVAL = 3
local MAX_HOP_COUNT = 50

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
	throughput = throughput or 0
	points = points or 0

	return "size[8,5;]"..
		"list[context;tapes;3.5,0;1,1;]"..
		"label[0,1.5;The computing center processes and stores experiment data to make discoveries.]"..
		"label[0,1.9;Connect this rack to an experiment or feed it tapes to gain points!]"..
		"label[0,2.3;Current network throughput: "..throughput.."MB/s, your team gains "..points.." points/s]"..
		"list[current_player;main;0,4;8,1;]"
end

minetest.register_node(":reseau:receiverscreen", {
	description = "Receiver (Testing)",
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
				local throughput_limit = 1000 -- TODO
				local throughput = throughput_limit > packet.throughput and packet_throughput or throughput_limit

				local dp = throughput * TX_INTERVAL * reseau.era.dp_multiplier
				teams.add_points(packet.team, dp)

				-- Update formspec
				local meta = minetest.get_meta(pos)
				meta:set_string("formspec", receiver_get_formspec(meta, throughput, dp / TX_INTERVAL))

				return throughput
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

minetest.register_node(":reseau:receiverbase", {
	drawtype = "nodebox",
	description = "Receiver Base",
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
local function get_merger_infotext(cache, max_cache)
	return "Router: (" .. cache .. " MB/" .. max_cache .. " MB)"
end

for _, team in ipairs(teams.get_all()) do
	minetest.register_node(":reseau:merger_" .. team.name, {
		description = "Router (Merging)",
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
					local max_cache = reseau.era.router_max_cache / TX_INTERVAL
					local available = max_cache - cache
					local used = math.min(available, packet.throughput)
					meta:set_int("cache", cache + used)
					meta:set_int("hop_count", math.max(hop_count, packet.hop_count))
					meta:set_string("infotext", get_merger_infotext(cache * TX_INTERVAL, reseau.era.router_max_cache))
					return used
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

						if cache > 0 then
							-- try to transmit as much data as possible via network
							local node = minetest.get_node(pos)
							local cablepos = vector.add(pos, minetest.facedir_to_dir(node.param2))
							local throughput = reseau.transmit(pos, cablepos, {
								throughput = cache,
								team = team.name,
								hop_count = hop_count + 1
							})

							cache = cache - throughput
							assert (cache >= 0)
							meta:set_int("hop_count", 0)
							meta:set_int("cache", cache)
							meta:set_string("infotext", get_merger_infotext(cache * TX_INTERVAL, reseau.era.router_max_cache))
						end
					end
				}
			}
		}
	})
end

local function get_splitter_infotext(cache, max_cache)
	return "Splitter: (" .. cache .. " MB/" .. max_cache .. " MB)"
end

for _, team in ipairs(teams.get_all()) do
	minetest.register_node(":reseau:splitter_" .. team.name, {
		description = "Router (Splitting)",
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
					local max_cache = reseau.era.splitter_max_cache / TX_INTERVAL
					local available = max_cache - cache
					local used = math.min(available, packet.throughput)
					meta:set_int("cache", cache + used)
					meta:set_int("hop_count", math.max(hop_count, packet.hop_count))
					meta:set_string("infotext", get_splitter_infotext(cache * TX_INTERVAL, reseau.era.splitter_max_cache))
					return used
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
						local first_side = meta:get_int("first_side") or 0
						meta:set_int("first_side", 1 - first_side)
						local node = minetest.get_node(pos)
						local rules = reseau.mergetable(
							reseau.rotate_rules_left({minetest.facedir_to_dir(node.param2)}),
							reseau.rotate_rules_right({minetest.facedir_to_dir(node.param2)})
						)
						assert (#rules == 2)
						if first_side == 1 then
							rules = { rules[2], rules[1] }
						end

						for _, dir in ipairs(rules) do
							if cache > 0 then
								-- try to transmit as much data as possible via network
								local cablepos = vector.add(pos, dir)
								local throughput = reseau.transmit(pos, cablepos, {
									throughput = cache,
									team = team.name,
									hop_count = hop_count + 1
								})

								cache = cache - throughput
								assert (cache >= 0)
							end
						end

						meta:set_int("hop_count", 0)
						meta:set_int("cache", cache)
						meta:set_string("infotext", get_splitter_infotext(cache * TX_INTERVAL, reseau.era.splitter_max_cache))
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

local experiment_get_formspec = function(meta, throughput)
	throughput = throughput or 0
	local cache = meta:get_int("cache")

	return "size[8,5;]"..
		"list[context;tapes;2,0;4,1;]"..
		"label[0,1.5;Experiments generate data that has to be moved to the computing center.]"..
		"label[0,1.9;Data can be transported manually by carrying tapes or by a network link.]"..
		"label[0,2.3;Data generation speed: "..reseau.era.genspeed.." MB/s]"..
		"label[0,2.7;Cached data: "..cache.." MB / Tape capacity: "..reseau.era.tape_capacity.." MB]"..
		"label[0,3.1;Network throughput: "..throughput.." MB/s]"..
		"list[current_player;main;0,4;8,1;]"
end

for _, team in ipairs(teams.get_all()) do
	minetest.register_node(":reseau:experiment_" .. team.name, {
		description = "Experiment",
		tiles = {"default_lava.png"},
		groups = {cracky = 3},
		groups = { ["protection_" .. team.name] = 1 },
		team_name = team.name,
		light_source = 10,
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = {
			reseau.with_overlay("reseau_experiment_top.png", team.color, "reseau_experiment_top_overlay.png"),
			reseau.with_overlay("reseau_experiment_bottom_overlay.png", team.color, "reseau_experiment_bottom_overlay.png"),
			reseau.with_overlay("reseau_experiment_side_connection.png", team.color, "reseau_experiment_side_connection_overlay.png"),
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

			meta:set_string("formspec", experiment_get_formspec(meta))
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
						cache = cache + reseau.era.genspeed * TX_INTERVAL

						-- try to transmit as much data as possible via network
						local throughput = reseau.transmit_first(pos, {
							throughput = cache / TX_INTERVAL,
							team = team.name,
							hop_count = 0
						})

						-- if there is enough cached data to put on a tape, just
						-- write a tape
						cache = cache - throughput * TX_INTERVAL
						if cache > reseau.era.tape_capacity then
							cache = cache - reseau.era.tape_capacity

							local inv = meta:get_inventory()
							local tape_stack = ItemStack("reseau:tape 1")
							local tape_meta = tape_stack:get_meta()
							tape_meta:set_int("capacity", reseau.era.tape_capacity)
							tape_meta:set_string("team", team.name)
							local desc = reseau.era.tape_capacity.." MB tape (team " .. team.name .. ")"
							tape_meta:set_string("description", desc)

							if inv:room_for_item("tapes", tape_stack) then
								inv:add_item("tapes", tape_stack)
							else
								cache = reseau.era.tape_capacity
							end
						end

						-- update node metadata
						meta:set_int("cache", cache)
						meta:set_string("formspec", experiment_get_formspec(meta, throughput))
					end
				}
			}
		}
	})
end

-- ######################
-- #        Tape        #
-- ######################
minetest.register_craftitem(":reseau:tape", {
	image = "reseau_tape.png",
	stack_max = 1,
	description="Data Tape"
})
