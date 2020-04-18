local actions = {}

function actions.join(meta, player, p, fields)
	if p.player then
		return false, "Barter slot is already occupied."
	end
	local team = teams.get_by_player(player)
	if not team then
		return false, "Where's your team?"
	end
	local pos = barter_table.positions[player:get_player_name()]
	local parties = barter_table.get_parties(pos)
	for k, p2 in pairs(parties) do
		--if p2.team == team then -- same table reference
			--return false, "Your team already opened a slot"
		--end
	end
	meta:set_string("player_" .. p.id, player:get_player_name())
	return true, "Opened slot " .. p.id
end

function actions.confirm(meta, player, p, fields)
	local name = player:get_player_name()
	-- Only the player can confirm
	if p.player ~= name then
		return false, "You have no permissions for this action."
	end
	meta:set_int("accept_" .. p.id, 1)
	return true
end

function actions.abort(meta, player, p, fields)
	local team = teams.get_by_player(player)
	-- Any team member can abort
	if team ~= p.team and p.team then
		return false, "Action denied: Team mismatch"
	end
	meta:set_int("accept_" .. p.id, 0)
	return true
end

function actions.leave(meta, player, p, fields)
	local name = player:get_player_name()
	local inv = meta:get_inventory()
	local is_empty = inv:is_empty("inv_" .. p.id)

	-- Allow leaving only to the player or when the slots are empty
	if p.player ~= name and not is_empty then
		return false, "Action denied: Player name mismatch"
	end
	if not is_empty then
		return false, "Action denied: Empty the slots first."
	end
	barter_table.meta_reset(meta, p.id)
	return true, "Left the trade!"
end

function actions.exchange(meta, player, p, fields)
	local name = player:get_player_name()
	if p.player ~= name then
		return false, "Action denied: Player name mismatch"
	end
	local parties = barter_table.get_parties(nil, meta)
	for k, p2 in pairs(parties) do
		if not p2.accepted then
			return false, "Both parties need to agree on the deal."
		end
	end

	local get_player_by_name = minetest.get_player_by_name
	-- Find best matching person to give the stuff
	-- Also allows trading when the initiator left
	local function get_best_matching(p2)
		if get_player_by_name(p2.player) then
			return p2.player
		end
		for name2, _ in pairs(barter_table.positions) do
			if teams.get_by_player(name2) == p2.team then
				return name2
			end
		end
		local members = teams.get_online_members(p2.team.name)
		return members[1]
	end

	local dst_party = {}
	do
		-- Counter-party:
		local pc_id = p.id == "a" and "b" or "a"
		local pc = parties[pc_id]
		local pc_player = get_best_matching(pc)
		if not pc_player then
			return false, "Trade impossible: There is nobody online to trade"
		end
		pc.player = pc_player
		dst_party[p.id] = pc
		dst_party[pc_id] = p
	end

	-- Exchange technologies
	-- TODO

	-- Exchange inventory stuff
	local inv = meta:get_inventory()
	for k, _ in pairs(parties) do
		local leftover = inv:get_list("inv_" .. k)
		local player2 = get_player_by_name(dst_party[k].player)
		local dst_inv = player2:get_inventory()
		for i, stack in ipairs(leftover) do
			leftover[i] = dst_inv:add_item("main", stack)
		end
		dst_party[k].leftover = leftover
	end

	-- Write back to the swapped inventories
	for k, p2 in pairs(parties) do
		inv:set_list("inv_" .. k, p2.leftover)
		inv:set_size("inv_" .. k, 4)
		if inv:is_empty("inv_" .. k) then
			barter_table.meta_reset(meta, k)
		else
			minetest.chat_send_player(p2.player, minetest.colorize("#FF0",
				"Warning: Not enough space in your inventory"))
			meta:set_int("accept_" .. k, 0)
		end
	end
	return true, "Trade was a success!"
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "barter_table:formspec" then
		return
	end

	local name = player:get_player_name()
	local pos = barter_table.positions[name]
	if not pos then
		return
	end

	if fields.quit then
		barter_table.positions[name] = nil
		return
	end

	local meta = minetest.get_meta(pos)
	local parties = barter_table.get_parties(pos, meta)

	for i, p in pairs(parties) do
		for act_name, func in pairs(actions) do
			if fields[act_name .. "_" .. i] then
				print("pressed ", act_name .. "_" .. i)
				local refresh, msg = func(meta, player, p, fields)
				if msg then
					minetest.chat_send_player(name, minetest.colorize(
						refresh and "#4F4" or "#F44", msg))
				end
				if refresh then
					barter_table.show_formspec(nil, pos)
				end
				return
			end
		end
	end
end)

-- Clean up garbage
minetest.register_on_leaveplayer(function(player)
	barter_table.positions[player:get_player_name()] = nil
end)
