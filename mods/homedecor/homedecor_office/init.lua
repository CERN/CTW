
homedecor.register("filing_cabinet", {
	description = "Filing cabinet",
	mesh = "homedecor_filing_cabinet.obj",
	tiles = {
		homedecor.plain_wood,
		"homedecor_filing_cabinet_front.png",
		"homedecor_filing_cabinet_bottom.png"
	},
	groups = { snappy = 3 },
	sounds = default.node_sound_wood_defaults(),
	infotext="Filing cabinet",
	inventory = {
		size=16,
	},
})

local desk_cbox = {
	type = "fixed",
	fixed = { -0.5, -0.5, -0.5, 1.5, 0.5, 0.5 }
}
homedecor.register("desk", {
	description = "Desk",
	mesh = "homedecor_desk.obj",
	tiles = {
		homedecor.plain_wood,
		"homedecor_desk_drawers.png",
		{ name = "homedecor_generic_metal.png", color = homedecor.color_black }
	},
	inventory_image = "homedecor_desk_inv.png",
	selection_box = desk_cbox,
	collision_box = desk_cbox,
	sounds = default.node_sound_wood_defaults(),
	groups = { snappy = 3 },
	expand = { right="placeholder" },
	inventory = {
		size=24,
	},
})
