-- protection_TEAM = 1

teams.register_on_team_changed(function(player, team_def)
	local inv = player:get_inventory()
	-- Does not work on empty stack
	local stack = ItemStack("default:axe_wood")
	local meta = stack:get_meta()
	local caps = stack:get_tool_capabilities()

	caps.groupcaps["protection_" .. team_def.name] = {
		times = { [1] = 0.3, [2] = 0 }, uses = 0, maxlevel = 1
	}

	meta:set_tool_capabilities(caps)

	inv:set_width("hand", 1)
	inv:set_list("hand", { stack })
end)

minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if inventory_info.from_list == "hand" or
			inventory_info.listname == "hand" then
		return 0
	end
end)
