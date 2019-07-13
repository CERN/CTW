local S = minetest.get_translator("reseau")
local TX_INTERVAL = reseau.TX_INTERVAL
local MAX_HOP_COUNT = reseau.MAX_HOP_COUNT

-- ######################
-- #      Routers       #
-- ######################

local function get_merger_infotext(throughput, throughput_limit)
	return S("Router: Current throughput @1 MB/s, maximum throughput @2 MB/s",
		reseau.throughput_string(throughput),
		reseau.throughput_string(throughput_limit))
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
	return S("Router: Current throughput @1 MB/s, maximum throughput @2 MB/s",
		reseau.throughput_string(throughput),
		reseau.throughput_string(throughput_limit))
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
