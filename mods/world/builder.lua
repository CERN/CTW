local conf_path = minetest.get_worldpath() .. "/world.conf"
if file_exists(conf_path) then
	world.load_locations(conf_path)
else
	minetest.log("error", "Map configuration for this world not found")
end

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

local function pos_to_string(pos)
	return ("%d,%d,%d"):format(pos.x, pos.y, pos.z)
end

local HELP = ([[
Click 'set' to set positions to the current position.
Click 'update' to create or update a location with the given location name.
Areas are defined using locations x_1 and x_, where x is the area name.
Click 'export' to create world.conf and world.mts at world/exports/.
]]):trim()

sfinv.register_page("world:builder", {
	title = "World Meta",
	get = function(self, player, context)
		local area = world.get_area("world") or { from = vector.new(), to = vector.new() }

		local fs = {
			"real_coordinates[true]",
			"container[0.375,0.375]",
			"field[0,0.3;3.75,0.8;from;From;", pos_to_string(area.from), "]",
			"button[3.75,0.3;1,0.8;set_from;Set]",
			"field[5,0.3;3.75,0.8;to;To;", pos_to_string(area.to), "]",
			"button[8.75,0.3;1,0.8;set_to;Set]",
			"container_end[]",

			"container[0.375,2.225]",
			"box[-0.375,-0.375;10.375,6;#666666cc]",
			"vertlabel[-0.2,1.2;LOCATIONS]",
			"textlist[0,0;9.625,4;locations;;]",
			"container[0,4.5]",
			"field[0,0;3.25,0.8;location_name;Name;", context.location_name or "world_1", "]",
			"field[3.5,0;2.75,0.8;location_pos;Position;", pos_to_string(context.location_pos or vector.new()), "]",
			"button[6.25,0;1,0.8;location_set;Set]",
			"button[7.5,0;2,0.8;location_update;Update]",
			"container_end[]",
			"container_end[]",

			"container[0.375,8.225]",
			"textarea[0,0;9.625,2;;;", minetest.formspec_escape(HELP), "]",
			"container_end[]",

			"button[3.75,9.6;3,0.8;export;Export]",

			-- 8,5.6   10.75,8.25
		}

		return sfinv.make_formspec(player, context,
				table.concat(fs, ""), false)
	end,
})
