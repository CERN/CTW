local function reg_extend(name, base, ext)
	for key, value in pairs(base) do
		ext[key] = ext[key] or base[key]
	end
	minetest.register_node(name, ext)
end

for tname, _ in pairs(teams.get_dict()) do
	local empty_name = "pallets:pallet_" .. tname
	local full_name = "pallets:pallet_full_" .. tname

	local base = {
		description = tname .. " pallet",
		pallets_empty_name = empty_name,
		pallets_full_name = full_name,
		drawtype = "nodebox",
		paramtype = "light",
		after_place_node = function(pos)
			if world.get_team_location(tname, "pallet") then
				minetest.set_node(pos, { name = "air" })
				return
			end

			world.set_team_location(tname, "pallet", pos)
			local suc, msg = pallets.deliver(tname, ItemStack("default:stone"))
			if not suc then
				minetest.chat_send_all(msg)
			end
		end,
		on_rightclick = function(pos, node, puncher)
			local team = teams.get_by_player(puncher)
			if not puncher or not team or team.name ~= tname then
				minetest.chat_send_player(puncher:get_player_name(), "You are not in team " .. tname .. "!")
				return
			end

			local chestinv = "nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z
			local fs = {
				"size[8,2.3]",
				default.gui_slots,
				"list[current_player;main;0,1.25;8,1;]",
				"list[", chestinv, ";main;0,0;4,1;]",
				"listring[]",
			}

			minetest.show_formspec(puncher:get_player_name(), "pallets:chest", table.concat(fs, ""))
		end,
		allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			return 0
		end,
		allow_metadata_inventory_take = function(pos, listname, index, stack, player)
			local team = teams.get_by_player(player)
			if not team or team.name ~= tname then
				return 0
			else
				return stack:get_count()
			end
		end,
		on_metadata_inventory_take = function(pos, listname, index, stack, player)
			local inv = minetest.get_inventory({ type = "node", pos = pos })
			local is_empty = inv:is_empty(listname)
			local correct_name = is_empty and empty_name or full_name
			if correct_name ~= minetest.get_node(pos).name then
				minetest.swap_node(pos, { name = correct_name })
			end
		end,
	}

	reg_extend(empty_name, base, {
		tiles = {
			"default_wood.png",
			"default_wood.png",
			"pallets_side.png",
			"pallets_side.png",
			"pallets_side.png",
			"pallets_side.png"
		},
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},
			}
		},
	})

	reg_extend(full_name, base, {
		tiles = {
			"pallets_top.png",
			"pallets_top.png",
			"pallets_side.png",
			"pallets_side.png",
			"pallets_side.png",
			"pallets_side.png"
		},
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},
				{-0.3125, -0.375, -0.3125, 0.3125, 0.125, 0.3125},
			}
		}
	})
end


pallets = {}

local _on_deliver = {}

function pallets.register_on_deliver(func)
	table.insert(_on_deliver, func)
end

function pallets.deliver(tname, stack)
	local pos = world.get_team_location(tname, "pallet")
	if not pos then
		return false, "Unable to find pallet"
	end

	local inv = minetest.get_meta(pos):get_inventory()
	inv:set_size("main", 4)
	if not inv:room_for_item("main", stack) then
		return false, "No room for delivery"
	end
	inv:add_item("main", stack)

	local nodename = minetest.get_node(pos).name
	local def = assert(minetest.registered_items[nodename])
	minetest.swap_node(pos, { name = def.pallets_full_name })

	for i=1, #_on_deliver do
		_on_deliver(tname, stack, pos)
	end

	local stackdef = minetest.registered_items[stack:get_name()]
	local desc = stackdef and stackdef.description or stack:get_name()
	teams.chat_send_team(tname, "Delivery arrived: " .. desc)

	return true, nil
end
