-- This code supplies an oven/stove. Basically it's just a copy of the default furnace with different textures.

local S = homedecor.gettext

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then return end
	node.name = name
	minetest.swap_node(pos, node)
end

local function make_formspec(furnacedef, percent)
	local fire

	if percent and (percent > 0) then
		fire = ("%s^[lowpart:%d:%s"):format(
			furnacedef.fire_bg,
			(100-percent),
			furnacedef.fire_fg
		)
	else
		fire = "default_furnace_fire_bg.png"
	end

	local w = furnacedef.output_width
	local h = math.ceil(furnacedef.output_slots / furnacedef.output_width)

	return "size["..math.max(8, 6 + w)..",9]"..
		"image[2,2;1,1;"..fire.."]"..
		"list[current_name;fuel;2,3;1,1;]"..
		"list[current_name;src;2,1;1,1;]"..
		"list[current_name;dst;5,1;"..w..","..h..";]"..
		"list[current_player;main;0,5;8,4;]"..
		"listring[current_name;dst]"..
		"listring[current_player;main]"..
		"listring[current_name;src]"..
		"listring[current_player;main]"
end

--[[
furnacedef = {
	description = "Oven",
	tiles = { ... },
	tiles_active = { ... },
	^ +Y -Y +X -X +Z -Z
	tile_format = "oven_%s%s.png",
	^ First '%s' replaced by one of "top", "bottom", "side", "front".
	^ Second '%s' replaced by "" for inactive, and "_active" for active "front"
	^ "side" is used for left, right and back.
	^ tiles_active for front is set
	output_slots = 4,
	output_width = 2,
	cook_speed = 1,
	^ Higher values cook stuff faster.
	extra_nodedef_fields = { ... },
	^ Stuff here is copied verbatim into both active and inactive nodedefs
	^ Useful for overriding drawtype, etc.
}
]]

local function make_tiles(tiles, fmt, active)
	if not fmt then return tiles end
	tiles = { }
	for i,side in ipairs{"top", "bottom", "side", "side", "side", "front"} do
		if active and (i == 6) then
			tiles[i] = fmt:format(side, "_active")
		else
			tiles[i] = fmt:format(side, "")
		end
	end
	return tiles
end

local furnace_can_dig = function(pos,player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("fuel")
		and inv:is_empty("dst")
		and inv:is_empty("src")
end

function homedecor.register_furnace(name, furnacedef)
	furnacedef.fire_fg = furnacedef.fire_bg or "default_furnace_fire_fg.png"
	furnacedef.fire_bg = furnacedef.fire_bg or "default_furnace_fire_bg.png"

	furnacedef.output_slots = furnacedef.output_slots or 4
	furnacedef.output_width = furnacedef.output_width or 2

	furnacedef.cook_speed = furnacedef.cook_speed or 1

	local description = furnacedef.description or "Furnace"

	local furnace_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", make_formspec(furnacedef, 0))
		meta:set_string("infotext", description)
		local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("src", 1)
		inv:set_size("dst", furnacedef.output_slots)
	end

	local furnace_allow_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				if inv:is_empty("src") then
					meta:set_string("infotext", "@1 (empty)", description)
				end
				return stack:get_count()
			else
				return 0
			end
		elseif listname == "src" then
			return stack:get_count()
		elseif listname == "dst" then
			return 0
		end
	end
	local furnace_allow_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		if to_list == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				if inv:is_empty("src") then
					meta:set_string("infotext", "@1 (empty)", description)
				end
				return count
			else
				return 0
			end
		elseif to_list == "src" then
			return count
		elseif to_list == "dst" then
			return 0
		end
	end

	local def = {
		description = description,
		tiles = make_tiles(furnacedef.tiles, furnacedef.tile_format, false),
		groups = furnacedef.groups or {cracky=2},
		sounds = furnacedef.sounds or default.node_sound_wood_defaults(),
		on_construct = furnace_construct,
		can_dig = furnace_can_dig,
		allow_metadata_inventory_put = furnace_allow_put,
		allow_metadata_inventory_move = furnace_allow_move,
		inventory = { lockable = false }
	}

	local def_active = {
		description = "@1 (active)", description,
		tiles = make_tiles(furnacedef.tiles_active, furnacedef.tile_format, true),
		light_source = 8,
		drop = "homedecor:" .. name,
		groups = furnacedef.groups or {cracky=2, not_in_creative_inventory=1},
		sounds = furnacedef.sounds or default.node_sound_stone_defaults(),
		on_construct = furnace_construct,
		can_dig = furnace_can_dig,
		allow_metadata_inventory_put = furnace_allow_put,
		allow_metadata_inventory_move = furnace_allow_move,
		inventory = { lockable = false }
	}

	if furnacedef.extra_nodedef_fields then
		for k, v in pairs(furnacedef.extra_nodedef_fields) do
			def[k] = v
			def_active[k] = v
		end
	end

	local n_active = name.."_active"

	homedecor.register(name, def)
	homedecor.register(n_active, def_active)

	local nname, name_active = "homedecor:"..name, "homedecor:"..n_active

	minetest.register_abm({
		nodenames = {nname, name_active, nname.."_locked", name_active.."_locked"},
		label = "furnaces",
		interval = 1.0,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local meta = minetest.get_meta(pos)
			for i, pname in ipairs({
					"fuel_totaltime",
					"fuel_time",
					"src_totaltime",
					"src_time"
			}) do
				if meta:get_string(pname) == "" then
					meta:set_float(pname, 0.0)
				end
			end

			local inv = meta:get_inventory()

			local srclist = inv:get_list("src")
			local cooked = nil
			local aftercooked

			if srclist then
				cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
			end

			local was_active = false

			if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
				was_active = true
				meta:set_float("fuel_time", meta:get_float("fuel_time") + 1)
				meta:set_float("src_time", meta:get_float("src_time") + furnacedef.cook_speed)
				if cooked and cooked.item and meta:get_float("src_time") >= cooked.time then
					-- check if there's room for output in "dst" list
					if inv:room_for_item("dst",cooked.item) then
						-- Put result in "dst" list
						inv:add_item("dst", cooked.item)
						-- take stuff from "src" list
						inv:set_stack("src", 1, aftercooked.items[1])
					end
					meta:set_string("src_time", 0)
				end
			end

			-- XXX: Quick patch, make it better in the future.
			local locked = node.name:find("_locked$") and "_locked" or ""
			local desc = minetest.registered_nodes[nname..locked].description

			if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
				local percent = math.floor(meta:get_float("fuel_time") /
						meta:get_float("fuel_totaltime") * 100)
				meta:set_string("infotext", "@1 (active: @2%)", desc, percent)
				swap_node(pos,name_active..locked)
				meta:set_string("formspec", make_formspec(furnacedef, percent))
				return
			end

			local fuel = nil
			local afterfuel
			cooked = nil
			local fuellist = inv:get_list("fuel")
			srclist = inv:get_list("src")

			if srclist then
				cooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
			end
			if fuellist then
				fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
			end

			if (not fuel) or (fuel.time <= 0) then
				meta:set_string("infotext", "@1 (out of fuel)", desc)
				swap_node(pos, nname..locked)
				meta:set_string("formspec", make_formspec(furnacedef, 0))
				return
			end

			if cooked.item:is_empty() then
				if was_active then
					meta:set_string("infotext", "@1 (empty)", desc)
					swap_node(pos, nname..locked)
					meta:set_string("formspec", make_formspec(furnacedef, 0))
				end
				return
			end

			if not inv:room_for_item("dst", cooked.item) then
				meta:set_string("infotext", "@1 (output bins are full)", desc)
				swap_node(pos, nname..locked)
				meta:set_string("formspec", make_formspec(furnacedef, 0))
				return
			end

			meta:set_string("fuel_totaltime", fuel.time)
			meta:set_string("fuel_time", 0)

			inv:set_stack("fuel", 1, afterfuel.items[1])
		end,
	})

end
