
homedecor.register("filing_cabinet", {
	description = "Filing Cabinet",
	mesh = "homedecor_filing_cabinet.obj",
	tiles = {
		{ name = "homedecor_generic_wood_plain.png",  color = 0xffa76820 },
		"homedecor_filing_cabinet_front.png",
		"homedecor_filing_cabinet_bottom.png"
	},
	groups = { snappy = 3 },
	sounds = default.node_sound_wood_defaults(),
})

homedecor.register("desk", {
	description = "Desk",
	mesh = "homedecor_desk.obj",
	tiles = {
		{ name = "homedecor_generic_wood_plain.png",  color = 0xffa76820 },
		"homedecor_desk_drawers.png",
		{ name = "homedecor_generic_metal.png", color = 0xff303030 }
	},
	inventory_image = "homedecor_desk_inv.png",
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 1.5, 0.5, 0.5 }
	},
	collision_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 1.5, 0.5, 0.5 }
	},
	sounds = default.node_sound_wood_defaults(),
	groups = { snappy = 3 },
	expand = { right="placeholder" },
})
