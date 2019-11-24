
local teamnames = { "red", "blue", "green", "yellow" }
for _, tname in pairs(teamnames) do
	minetest.register_node(":pallets:pallet_" .. tname, {
		description = tname .. " pallet",
		drawtype = "nodebox",
		paramtype = "light",
		tiles = {
			"default_wood.png^[colorize:" .. tname .. ":0.1",
		},
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},
			}
		},
		groups = { snappy = 3 },
		after_place_node = function(pos)
			minetest.get_meta(pos):set_string("infotext", minetest.pos_to_string(pos))
			world.set_team_location(tname, "pallet", pos)
		end,
	})

	minetest.register_node(":reseau:receiver_" .. tname, {
		description = tname .. " receiver",
		tiles = {
			"baked_clay_white.png",
			"baked_clay_white.png",
			"baked_clay_white.png",
			"baked_clay_white.png",
			"baked_clay_" .. tname .. ".png",
			"baked_clay_white.png",
		},
		paramtype2 = "facedir",
		inventory_image = "baked_clay_" .. tname .. ".png",
		groups = { snappy = 3 },
	})

	local experiment_name = "reseau:experiment_" .. tname
	minetest.register_node(":" .. experiment_name, {
		description = "Experiment for " .. tname,
		groups = { snappy = 3 },
		team_name = tname,
		light_source = 10,
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = {
			"default_gold_block.png^[colorize:" .. tname .. ":0.1",
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
	})
end

minetest.register_node(":team_billboard:bb", {
	description = "Team Billboard",
	drawtype = "signlike",
	visual_scale = 2.0,
	tiles = { "wool_black.png" },
	inventory_image = "wool_black.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 1, -- reflecting a bit of light might be expected
	selection_box = { type = "wallmounted" },
	groups = {attached_node=1, snappy=1},
	legacy_wallmounted = true,
})

minetest.register_node(":computer:server", {
	drawtype = "nodebox",
	description = "Rack Server",
	tiles = {
		'computer_server_t.png',
		'computer_server_bt.png',
		'computer_server_l.png',
		'computer_server_r.png',
		'computer_server_bt.png',
		'computer_server_f_off.png'
	},
	inventory_image = "computer_server_inv.png",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=3},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5+2/16, 0.5, 1.125, 0.5-3/16}
	},
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5+2/16, 0.5, 1.125, 0.5-3/16}
	},
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		if minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name ~= "air" then
			minetest.chat_send_player( placer:get_player_name(),
					"Not enough vertical space to place a server!")
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end
})
