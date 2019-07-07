computer = {}

-- Functions

computer.register = function (name, def)
	if (name:sub(1, 1) == ":") then name = name:sub(2) end
	local modname, basename = name:match("^([^:]+):(.*)")
	local TEXPFX = modname.."_"..basename.."_"
	local ONSTATE = modname..":"..basename
	local OFFSTATE = modname..":"..basename.."_off"
	local cdef = table.copy(def)
	minetest.register_node(ONSTATE, {
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		description = cdef.description,
		inventory_image = cdef.inventory_image,
		groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2},
		tiles = {
			TEXPFX.."tp.png",
			TEXPFX.."bt.png",
			TEXPFX.."rt.png",
			TEXPFX.."lt.png",
			TEXPFX.."bk.png",
			TEXPFX.."ft.png"
		},
		node_box = cdef.node_box,
		selection_box = cdef.node_box,
		on_rightclick = function (pos, node, clicker, itemstack)
			if cdef.on_turn_off and cdef.on_turn_off(pos, node, clicker, itemstack) then
				return itemstack
			end
			node.name = OFFSTATE
			minetest.set_node(pos, node)
			return itemstack
		end
	})

	minetest.register_node(OFFSTATE, {
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
		tiles = {
			(TEXPFX.."tp"..(cdef.tiles_off.top	and "_off" or "")..".png"),
			(TEXPFX.."bt"..(cdef.tiles_off.bottom and "_off" or "")..".png"),
			(TEXPFX.."rt"..(cdef.tiles_off.right  and "_off" or "")..".png"),
			(TEXPFX.."lt"..(cdef.tiles_off.left   and "_off" or "")..".png"),
			(TEXPFX.."bk"..(cdef.tiles_off.back   and "_off" or "")..".png"),
			(TEXPFX.."ft"..(cdef.tiles_off.front  and "_off" or "")..".png")
		},
		node_box = cdef.node_box_off or cdef.node_box,
		selection_box = cdef.node_box_off or cdef.node_box,
		on_rightclick = function (pos, node, clicker, itemstack)
			if cdef.on_turn_on and cdef.on_turn_on(pos, node, clicker, itemstack) then
				return itemstack
			end
			node.name = ONSTATE
			minetest.set_node(pos, node)
			return itemstack
		end,
		drop = ONSTATE
	})
end

computer.pixelnodebox = function (size, boxes)
	local fixed = { }
	for _, box in ipairs(boxes) do
		local x, y, z, w, h, l = unpack(box)
		fixed[#fixed + 1] = {
			(x / size) - 0.5,
			(y / size) - 0.5,
			(z / size) - 0.5,
			((x + w) / size) - 0.5,
			((y + h) / size) - 0.5,
			((z + l) / size) - 0.5
		}
	end
	return {
		type = "fixed",
		fixed = fixed
	}
end

-- Amiga 500 lookalike
computer.register("computer:shefriendSOO", {
	description = "SheFriendSOO",
	tiles_off = { front=true },
	node_box = computer.pixelnodebox(32, {
		-- X   Y   Z   W   H   L
		{  0,  0, 17, 32, 32, 12 },   -- Monitor Screen
		{  3,  3, 29, 26, 26,  3 },   -- Monitor Tube
		{  0,  0,  0, 32,  4, 17 }   -- Keyboard
	})
})


-- Commodore 64 lookalike
computer.register("computer:admiral64", {
	description = "Admiral64",
	inventory_image = "computer_ad64_inv.png",
	tiles_off = { },
	node_box = computer.pixelnodebox(32, {
		-- X   Y   Z   W   H   L
		{  0,  0,  0, 32,  4, 18 }   -- Keyboard
	})
})

-- Commodore 128 lookalike
computer.register("computer:admiral128", {
	description = "Admiral128",
	inventory_image = "computer_ad128_inv.png",
	tiles_off = { },
	node_box = computer.pixelnodebox(32, {
		-- X   Y   Z   W   H   L
		{  0,  0,  0, 32,  4, 27 }   -- Keyboard
	})
})

--WIFI Router (linksys look-a-like)
minetest.register_node("computer:router", {
	description = "WIFI Router",
	inventory_image = "computer_router_inv.png",
	tiles = {
		"computer_router_t.png","computer_router_bt.png",
		"computer_router_l.png","computer_router_r.png",
		"computer_router_b.png",
		{name="computer_router_f_animated.png",
				animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=1.0}},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	groups = {snappy=3},
	sound = default.node_sound_wood_defaults(),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.0625, 0.25, -0.375, 0.3125},
			{-0.1875, -0.4375, 0.3125, -0.125, -0.1875, 0.375},
			{0.125, -0.4375, 0.3125, 0.1875, -0.1875, 0.375},
			{-0.0625, -0.4375, 0.3125, 0.0625, -0.25, 0.375}
		}
	}
})

--Rack Server
minetest.register_node("computer:server", {
	drawtype = "nodebox",
	description = "Rack Server",
	tiles = {
		'computer_server_t.png',
		'computer_server_bt.png',
		'computer_server_l.png',
		'computer_server_r.png',
		'computer_server_bt.png',
		'computer_server_f_off.png'
	},
	inventory_image = "computer_server_inv.png",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=3},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5+2/16, 0.5, 1.125, 0.5-3/16}
	},
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5+2/16, 0.5, 1.125, 0.5-3/16}
	},
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		node.name = "computer:server_on"
		minetest.set_node(pos, node)
		return itemstack
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		if minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name ~= "air" then
			minetest.chat_send_player( placer:get_player_name(),
					"Not enough vertical space to place a server!")
			return itemstack
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end
})

local function register_server(team)
	local common = "(teams_color32_" .. team .. ".png^[mask:computer_server_"
	local maskt = common .. "top.png)"
	local masks = common .. "side.png)"
	local maskb = common .. "back.png)"
	minetest.register_node("computer:server_" .. team, {
		drawtype = "nodebox",
		tiles = {
			'computer_server_t.png^[resize:32x32^' .. maskt,
			'computer_server_bt.png',
			'computer_server_l.png^' .. masks,
			'computer_server_r.png^(' .. masks .. '^[transformFX)',
			'computer_server_bt.png^[resize:32x32^' .. maskb,
			'computer_server_f_on.png',
		},
		inventory_image = "computer_server_inv.png",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {["protection_" .. team]=1},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.25, 0.5, 1.125, 0.4375}
		},
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.25, 0.5, 1.125, 0.4375},
				{-0.125, -0.5, 0.4275, 0.125, -0.25, 0.5}, -- NodeBox2
			}
		},
		sounds = default.node_sound_wood_defaults()
	})
end

for i, team_def in ipairs(teams.get_all()) do
	register_server(team_def.name)
end

-- Printer/scaner combo
minetest.register_node("computer:printer", {
	description = "Printer-Scanner Combo",
	inventory_image = "computer_printer_inv.png",
	tiles = {"computer_printer_t.png","computer_printer_bt.png","computer_printer_l.png",
			"computer_printer_r.png","computer_printer_b.png","computer_printer_f.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = true,
	groups = {snappy=3},
	sound = default.node_sound_wood_defaults(),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.3125, -0.125, 0.4375, -0.0625, 0.375},
			{-0.4375, -0.5, -0.125, 0.4375, -0.4375, 0.375},
			{-0.4375, -0.5, -0.125, -0.25, -0.0625, 0.375},
			{0.25, -0.5, -0.125, 0.4375, -0.0625, 0.375},
			{-0.4375, -0.5, -0.0625, 0.4375, -0.0625, 0.375},
			{-0.375, -0.4375, 0.25, 0.375, -0.0625, 0.4375},
			{-0.25, -0.25, 0.4375, 0.25, 0.0625, 0.5},
			{-0.25, -0.481132, -0.3125, 0.25, -0.4375, 0}
		},
	},
})
