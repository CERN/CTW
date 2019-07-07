-- Detached inventory per team.
-- Those inventories are weak, the actual state of them is always determined by the idea states
-- in case of a game restart
-- Lists:
-- ideas - for ideas
-- approvals - for approval letters


local function check_team(player, tname)
	local team = teams.get_by_player(player)
	return team and team.name == tname
end


local pub_msgs = {
already_published = "This idea has already been published. It could even be invented by now!"
}
local inv_msgs = {
no_approval_letter = "This is not an approval letter",
wrong_team = "This letter was issued for another team! Give it back to them!",
not_approved = "This letter is a fake!",
already_invented = "This technology has already been invented!"
}


local inv_callbacks = {
			allow_move = function(tname, inv, from_list, from_index, to_list, to_index, count, player)
				if not check_team(player, tname) then return 0 end
				-- only allows movement within the same list
				--if from_list == to_list then
				--	return count
				--end
				return 0
			end,
			-- Called when a player wants to move items inside the inventory.
			-- Return value: number of items allowed to move.

			allow_put = function(tname, inv, listname, index, stack, player)
				if not check_team(player, tname) then return 0 end
				local pname = player:get_player_name()
				-- only allows putting in certain items into certain list
				if listname == "ideas" then
					-- only "idea" items are permitted
					if minetest.get_item_group(stack:get_name(), "ctw_idea") > 0 then
						local idef = minetest.registered_items[stack:get_name()]
						local idea_id = idef._ctw_idea_id
						if idea_id then
							-- You can always put ideas in. if they are already present,
							-- this simply means that the additional item is removed.
							return 1
						end
					end
				elseif listname == "approvals" then
					-- only "approval" items are permitted
					local team = teams.get(tname)
					local succ, err = ctw_resources.start_inventing(stack, team, pname)
					if not succ and (err=="no_approval_letter" or err == "wrong_team") then
						return 0
					end
					-- this will consume faked letters
					return 1
				end
				return 0
			end,
			-- Called when a player wants to put something into the inventory.
			-- Return value: number of items allowed to put.
			-- Return value -1: Allow and don't modify item count in inventory.

			allow_take = function(tname, inv, listname, index, stack, player)
				if not check_team(player, tname) then return 0 end
				if listname == "ideas" then
					return -1
				end
				return 0
			end,
			-- Called when a player wants to take something out of the inventory.
			-- Return value: number of items allowed to take.
			-- Return value -1: Allow and don't modify item count in inventory.

			on_put = function(tname, inv, listname, index, stack, player)
				if not check_team(player, tname) then return end
				local pname = player:get_player_name()
				-- only allows putting in certain items into certain list
				if listname == "ideas" then
					-- only "idea" items are permitted
					if minetest.get_item_group(stack:get_name(), "ctw_idea") > 0 then
						local idef = minetest.registered_items[stack:get_name()]
						local idea_id = idef._ctw_idea_id
						if idea_id then
							-- Idea is published in team!
							local team = teams.get(tname)
							local succ, err = ctw_resources.publish_idea(idea_id, team, pname)
							local msg
							if not succ then
								msg = pub_msgs[err]
							end

							minetest.after(0, function()
								team_billboard.rebuild_billboard_inventory(team)
								team_billboard.update_open_forms(tname, pname, msg)
							end)
						end
					end
				elseif listname == "approvals" then
					-- only "approval" items are permitted
					if minetest.get_item_group(stack:get_name(), "ctw_approval") > 0 then
						-- Idea is approved and in team space, let the fun begin!
						local team = teams.get(tname)
						local succ, err = ctw_resources.start_inventing(stack, team, pname)
						local msg
						if not succ then
							msg = inv_msgs[err]
						end

						minetest.after(0, function()
							team_billboard.rebuild_billboard_inventory(team)
							team_billboard.update_open_forms(tname, pname, msg)
						end)
					end
				end
			end,
			-- Called after the actual action has happened, according to what was
			-- allowed.
			-- No return value.
		}

-- Gets the billboard inventory and creates it if necessary.
-- if explicit_rebuild is set, resets contents even if it existed before
function team_billboard.get_billboard_inventory(team, explicit_rebuild)
	local inv = minetest.get_inventory({type="detached", name="team_billboard_"..team.name})
	if not inv then
		-- create inventory
		local tname = team.name
		minetest.create_detached_inventory("team_billboard_"..team.name, {
			allow_move = function(inv2, from_list, from_index, to_list, to_index, count, player)
				return inv_callbacks.allow_move(tname, inv2, from_list, from_index, to_list, to_index, count, player)
			end,

			allow_put = function(inv2, listname, index, stack, player)
				return inv_callbacks.allow_put(tname, inv2, listname, index, stack, player)
			end,

			allow_take = function(inv2, listname, index, stack, player)
				return inv_callbacks.allow_take(tname, inv2, listname, index, stack, player)
			end,

			on_put = function(inv2, listname, index, stack, player)
				return inv_callbacks.on_put(tname, inv2, listname, index, stack, player)
			end,
		})
	end

	if not inv or explicit_rebuild then
		inv = team_billboard.rebuild_billboard_inventory(team)
	end

	return inv
end

-- Empties and re-constructs the contents of the team billboard inventory based on idea states of the team.
function team_billboard.rebuild_billboard_inventory(team)
	local inv = minetest.get_inventory({type="detached", name="team_billboard_"..team.name})

	inv:set_lists({
		ideas = {},
		approvals = {},
	})
	inv:set_size("ideas", 1*6)
	inv:set_size("approvals", 1*6)

	for idea_id, idea in pairs(ctw_resources._get_ideas()) do
		local istate = ctw_resources.get_team_idea_state(idea_id, team)
		if istate.state=="published" or istate.state == "approved" or istate.state == "inventing" then
			--idea is present on team billboard
			inv:add_item("ideas", "ctw_resources:idea_"..idea_id)
		end
		if istate.state == "inventing" then
			-- approval letter is on team billboard
			inv:add_item("approvals", ctw_resources.get_approval_letter_istack(idea_id, idea, team))
		end
		-- When idea is invented, it disappears from the team billboard
	end
	return inv
end

ctw_resources.register_on_inventing_complete(function(team, idea_id)
	team_billboard.rebuild_billboard_inventory(team)
end)

-- Creates all billboard inventories, if not already present
function team_billboard.create_billboard_inventories()
	for _, team in ipairs(teams.get_all()) do
		team_billboard.get_billboard_inventory(team)
	end
end

-- Explicitly rebuilds all billboard inventories
function team_billboard.rebuild_billboard_inventories()
	for _, team in ipairs(teams.get_all()) do
		team_billboard.get_billboard_inventory(team, true)
	end
end
