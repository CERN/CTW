
local function N_(x) return x end

-- white, enameled fridge
homedecor.register("refrigerator_white", {
	mesh = "homedecor_refrigerator.obj",
	tiles = { "homedecor_refrigerator_white.png" },
	inventory_image = "homedecor_refrigerator_white_inv.png",
	description = "Refrigerator",
	groups = {snappy=3},
	selection_box = homedecor.nodebox.slab_y(2),
	collision_box = homedecor.nodebox.slab_y(2),
	sounds = default.node_sound_stone_defaults(),
	expand = { top="placeholder" },
	on_rotate = screwdriver.rotate_simple
})

-- Oven
minetest.register_node(":homedecor:oven", {
	description = "Oven",
	tiles = {
		"homedecor_oven_top.png",
		"homedecor_oven_bottom.png",
		"homedecor_oven_side.png",
		"homedecor_oven_side.png",
		"homedecor_oven_side.png",
		"homedecor_oven_front.png"
	},
	paramtype2 = "facedir",
	groups = {choppy = 2, flammable = 2, wood = 1},
	on_place = minetest.rotate_node
})


-- Kitchen Cabinet and sink
local cabinet_sides = "(default_wood.png^[transformR90)^homedecor_kitchen_cabinet_bevel.png"
local cabinet_bottom = "(default_wood.png^[colorize:#000000:100)^(homedecor_kitchen_cabinet_bevel.png^[colorize:#46321580)"

local function N_(x) return x end

homedecor.register("kitchen_cabinet_granite", {
	description = "Kitchen Cabinet",
	tiles = { 'homedecor_kitchen_cabinet_top_granite.png',
			cabinet_bottom,
			cabinet_sides,
			cabinet_sides,
			cabinet_sides,
			'homedecor_kitchen_cabinet_front.png'},
	groups = { snappy = 3 },
	sounds = default.node_sound_wood_defaults(),
})

homedecor.register("kitchen_cabinet_with_sink", {
	description = "Kitchen Cabinet with Sink",
	mesh = "homedecor_kitchen_sink.obj",
	tiles = {
		"homedecor_kitchen_sink_top.png",
		"homedecor_kitchen_cabinet_front.png",
		cabinet_sides,
		cabinet_bottom
	},
	groups = { snappy = 3 },
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16,  8/16, 6/16,  8/16 },
			{ -8/16,  6/16, -8/16, -6/16, 8/16,  8/16 },
			{  6/16,  6/16, -8/16,  8/16, 8/16,  8/16 },
			{ -8/16,  6/16, -8/16,  8/16, 8/16, -6/16 },
			{ -8/16,  6/16,  6/16,  8/16, 8/16,  8/16 },
		}
	},
	on_destruct = function(pos)
		homedecor.stop_particle_spawner({x=pos.x, y=pos.y+1, z=pos.z})
	end
})

homedecor.register("kitchen_faucet", {
	mesh = "homedecor_kitchen_faucet.obj",
	tiles = { "homedecor_generic_metal_bright.png" },
	inventory_image = "homedecor_kitchen_faucet_inv.png",
	description = "Kitchen Faucet",
	groups = {snappy=3},
	selection_box = {
		type = "fixed",
		fixed = { -2/16, -8/16, 1/16, 2/16, -1/16, 8/16 }
	},
	walkable = false,
	on_rotate = screwdriver.disallow,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local below = minetest.get_node_or_nil({x=pos.x, y=pos.y-1, z=pos.z})
		if below and
		  below.name == "homedecor:sink" or
		  below.name == "homedecor:kitchen_cabinet_with_sink" then
			local particledef = {
				outlet      = { x = 0, y = -0.19, z = 0.13 },
				velocity_x  = { min = -0.05, max = 0.05 },
				velocity_y  = -0.3,
				velocity_z  = { min = -0.1,  max = 0 },
				spread      = 0
			}
			homedecor.start_particle_spawner(pos, node, particledef, "homedecor_faucet")
		end
		return itemstack
	end,
	on_destruct = homedecor.stop_particle_spawner
})
