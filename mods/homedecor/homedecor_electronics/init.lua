
homedecor.register("telephone", {
	mesh = "homedecor_telephone.obj",
	tiles = {
		"homedecor_telephone_dial.png",
		"homedecor_telephone_base.png",
		"homedecor_telephone_handset.png",
		"homedecor_telephone_cord.png",
	},
	inventory_image = "homedecor_telephone_inv.png",
	description = "Telephone",
	groups = {snappy=3},
	selection_box = tel_cbox,
	walkable = false,
	sounds = default.node_sound_wood_defaults(),
})
