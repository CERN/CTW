local S = minetest.get_translator("reseau")
local TX_INTERVAL = reseau.TX_INTERVAL

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
	throughput = throughput and reseau.throughput_string(throughput) or 0
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

			meta:set_string("infotext", S("Experiment"))
			meta:set_string("formspec", experiment_get_formspec(experiment_name, meta))
		end,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			local player_team = teams.get_by_player(player)
			if player_team and player_team.name == team.name then
				return stack:get_count()
			end
			return 0
		end,
		allow_metadata_inventory_take = function(pos, listname, index, stack, player)
			local player_team = teams.get_by_player(player)
			if player_team and player_team.name == team.name then
				return stack:get_count()
			end
			return 0
		end,
		allow_metadata_inventory_move = function(pos, _, _, _, _, count, player)
			local player_team = teams.get_by_player(player)
			if player_team and player_team.name == team.name then
				return count
			end
			return 0
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

