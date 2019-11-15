-- table
minetest.register_node("furnishings:table", {
	description = "Table",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 5/16, -0.5, 0.5, 0.5, 0.5,},
			{-0.5, -0.5, -6/16, -6/16, 5/16, -0.5,},
			{-0.5, -0.5, 6/16, -6/16, 5/16, 0.5,},
			{0.5, -0.5, -6/16, 6/16, 5/16, -0.5,},
			{0.5, -0.5, 6/16, 6/16, 5/16, 0.5,},
		},
	},
	tiles = {"default_wood.png"},
	groups = {choppy = 2},
})

-- chair
minetest.register_node("furnishings:chair", {
	description = "Chair",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{5/16, 1/16, 5/16, -5/16, 0.5, 3/16,},
			{-5/16, -1/16, -5/16, 5/16, 1/16, 5/16,},
			{-5/16, -0.5, -3/16, -3/16, -1/16, -5/16,},
			{-5/16, -0.5, 3/16, -3/16, -1/16, 5/16,},
			{5/16, -0.5, -3/16, 3/16, -1/16, -5/16,},
			{5/16, -0.5, 3/16, 3/16, -1/16, 5/16,},
		},
	},
	tiles = {"default_wood.png"},
	groups = {choppy = 2},
})

-- shelf
-- note that free standing version has rotation issues
-- due to limitations in the engine. Safe for use in CTW
-- because players won't build directly
minetest.register_node("furnishings:shelves", {
	description = "Shelves",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"default_wood.png"},
	inventory_image = "default_wood.png",
	wield_image = "default_wood.png",
	groups = {choppy = 2,},
	node_box = {
		type = "connected",
		connect_left = {
			{-0.5, 0, -0.5, 0, 2/16, 0.5},
			{-0.5, -0.5, -0.5, 0, -6/16, 0.5},
		},
		connect_right = {
			{0, 0, -0.5, 0.5, 2/16, 0.5},
			{0, -0.5, -0.5, 0.5, -6/16, 0.5},
		},
		connect_front = {
			{-0.5, 0, -0.5, 0.5, 2/16, 0},
			{-0.5, -0.5, -0.5, 0.5, -6/16, 0},
		},
		connect_back = {
			{-0.5, 0, 0, 0.5, 2/16, 0.5},
			{-0.5, -0.5, 0, 0.5, -6/16, 0.5},
		},
		disconnected_sides  = {
			{-0.5, 0, -0.5, 0.5, 2/16, 0}, -- upper shelf
			{-0.5, -0.5, -0.5, 0.5, -6/16, 0}, --lower shelf
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.4}, -- back
			{0.4, -0.5, -0.5, 0.5, 0.5, 0}, -- left side
			{-0.4, -0.5, -0.5, -0.5, 0.5, 0}, -- right side
		}
	},
	connects_to = {"group:stone", "group:wood", "group:bakedclay"},
})
