
local clock_sbox = {
	type = "fixed",
	fixed = { -8/32, -8/32, 14/32, 8/32, 8/32, 16/32 }
}

local clock_materials = {
	{ "wood", "Wooden analog clock", "default_wood.png" }
}

for _, mat in ipairs(clock_materials) do
	local name, desc, tex = unpack(mat)
	homedecor.register("analog_clock_"..name, {
		description = desc,
		mesh = "homedecor_analog_clock.obj",
		tiles = {
			"homedecor_analog_clock_face.png",
			tex,
			"homedecor_analog_clock_back.png"
		},
		inventory_image = "homedecor_analog_clock_"..name.."_inv.png",
		walkable = false,
		selection_box = clock_sbox,
		groups = {snappy=3},
		sounds = default.node_sound_wood_defaults(),
	})
end
