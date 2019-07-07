
homedecor.register("analog_clock_wood", {
	description = "Analog Clock",
	mesh = "homedecor_analog_clock.obj",
	tiles = {
		"homedecor_analog_clock_face.png",
		"default_wood.png" ,
		"homedecor_analog_clock_back.png"
	},
	inventory_image = "homedecor_analog_clock_wood_inv.png",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -8/32, -8/32, 14/32, 8/32, 8/32, 16/32 }
	},
	groups = {snappy=3},
	sounds = default.node_sound_wood_defaults(),
})
