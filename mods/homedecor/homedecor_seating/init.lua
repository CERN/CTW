
homedecor.register("office_chair_basic", {
	description = "Basic office chair",
	drawtype = "mesh",
	tiles = { "homedecor_office_chair_basic.png" },
	mesh = "homedecor_office_chair_basic.obj",
	groups = { snappy = 3 },
	sounds = default.node_sound_wood_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, 29/32, 8/16 }
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{ -5/16,   1/16, -7/16,  5/16,   4/16,  7/16 }, -- seat
			{ -5/16,   4/16,  4/16,  5/16,  29/32, 15/32 }, -- seatback
			{ -1/16, -11/32, -1/16,  1/16,   1/16,  1/16 }, -- cylinder
			{ -8/16,  -8/16, -8/16,  8/16, -11/32,  8/16 }  -- legs/wheels
		}
	},
	expand = { top = "placeholder" },
	on_rotate = screwdriver.rotate_simple
})

