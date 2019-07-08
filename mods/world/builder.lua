local teamnames = { "red", "blue", "green", "yellow" }

for _, tname in pairs(teamnames) do
	minetest.register_node(":palettes:palette_" .. tname, {
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
