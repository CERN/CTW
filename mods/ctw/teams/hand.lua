-- protection_TEAM = 1
local dig_cap = { times = { [1] = 0.3, [2] = 0 }, uses = 0, maxlevel = 1 }
local team_hand = table.copy(minetest.registered_items[""])
local admin_caps = table.copy(team_hand.tool_capabilities or {})

-- Override the normal hand so that it cannot dig anything
team_hand.tool_capabilities = team_hand.tool_capabilities or {}
team_hand.tool_capabilities.groupcaps = {}

-- Add admin group caps
for _, team_def in ipairs(teams.get_all()) do
	admin_caps.groupcaps["protection_" .. team_def.name] = dig_cap
end

-- Make default hand useless (cannot modify groupcaps)
minetest.register_item(":", team_hand)
-- Superior team-specific hand to actually change
minetest.register_item("teams:hand", team_hand)

-- Update team hand definition
local function update_hand(player, team_def)
	local inv = player:get_inventory()
	-- Does not work on empty stack
	local stack = ItemStack("teams:hand")
	local meta = stack:get_meta()
	local caps = stack:get_tool_capabilities()

	if minetest.check_player_privs(player, { server = true }) then
		caps = admin_caps
	elseif team_def then
		caps.groupcaps["protection_" .. team_def.name] = dig_cap
	end

	meta:set_tool_capabilities(caps)

	inv:set_width("hand", 1)
	inv:set_list("hand", { stack })
end

teams.register_on_team_changed(update_hand)

minetest.register_on_joinplayer(function(player)
	update_hand(player, teams.get_by_player(player))
end)

-- Disallow (re)moving or replacing the hand
minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if inventory_info.from_list == "hand" or
			inventory_info.listname == "hand" then
		return 0
	end
end)
