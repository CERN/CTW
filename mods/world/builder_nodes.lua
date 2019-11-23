
local teamnames = { "red", "blue", "green", "yellow" }
for _, tname in pairs(teamnames) do
	minetest.register_node(":pallets:palette_" .. tname, {
		description = tname .. " palette",
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
		after_place_node = function(pos)
			minetest.get_meta(pos):set_string("infotext", minetest.pos_to_string(pos))
		end,
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
	groups = {attached_node=1},
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
