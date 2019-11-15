local S = minetest.get_translator("reseau")
local TX_INTERVAL = reseau.TX_INTERVAL

-- ######################
-- #     Receivers      #
-- ######################

local receiver_get_formspec = function(meta, throughput, points)
	throughput = throughput and reseau.throughput_string(throughput) or 0
	points = points and reseau.throughput_string(points) or 0
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
			{-0.5+3/16, -0.5+2/16, 5/16, 0.5-3/16, -0.5+11/16, 7/16}, -- screen bump
			{-0.5, -1.5, -6/16, 0.5, -0.5, 5/16}, -- Receiverbase
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

		meta:set_string("infotext", S("Receiver (testing)"))
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
			{-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
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
