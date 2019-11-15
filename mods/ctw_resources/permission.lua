-- Craft The Web
-- Permission letter received by the General Office NPC.

--[[
Once the General Office NPC approves an idea, it gives out an approval letter.
This needs to be taken to the team billboard.
Once it arrives there, the technology starts to be developed
]]--


-- Checks if the idea can be approved by the management, that is, permission
-- should be granted
--  techs_provided - list of technology IDs the team has achieved
--  refs_inv, refs_invlist - inventory (list) which contains the references
--  returns true when the technology is approved
--  returns false, technologies_missing, references_missing when the technology can not be approved
function ctw_resources.is_idea_approved(idea_id, team, refs_inv, refs_invlist)
	local idea = ctw_resources.get_idea(idea_id)

	local techs_m = {}
	local refs_m = {}
	-- check technologies
	for _,tech_id in ipairs(idea.technologies_required) do
		local tstate = ctw_technologies.get_team_tech_state(tech_id, team)
		if tstate.state == "undiscovered" then
			table.insert(techs_m, tech_id)
		end
	end
	-- check references
	for _,stack in ipairs(idea.references_required) do
		if not refs_inv:contains_item(refs_invlist, stack, false) then
			table.insert(refs_m, stack)
		end
	end
	if (#techs_m == 0) and (#refs_m == 0) then
		return true
	end
	return false, techs_m, refs_m
end


-- Approves an idea for a team
-- Get a permission letter for the passed idea, directed at the given team
-- idea_id: Idea that is approved for
-- pname: player applying for permission
-- if "try" is true, will only perform a dry run and do nothing actually.
-- Returns:
-- true - on success
-- false, error_reason - on failure
-- Error reasons:
-- error reasons:
	-- already_approved - Idea is already approved, that means, an approval letter has already been issued for this team
	-- no_team - Player has no team
	-- insufficient_resources - Player has not brought enough resources
	-- insufficient_techs - One or more required technologies are not discovered yet
function ctw_resources.approve_idea(idea_id, pname, inv, invlist, try)
	local idea = ctw_resources.get_idea(idea_id)

	local team = teams.get_by_player(pname)
	if not team then return false, "no_team" end

	if ctw_resources.compare_idea(idea_id, team, "gt", "approved") then
		return false, "already_approved"
	end

	-- For the case someone lost the idea item:
	local idea_team = ctw_resources.get_team_idea_state(idea_id, team)
	if idea_team.last_action and minetest.get_gametime() <
			idea_team.last_action + ctw_resources.LAST_ACTION_COOLDOWN then
		return false, "already_approved"
	end

	local appr_ok, m_tech, _ = ctw_resources.is_idea_approved(idea_id, team, inv, invlist)

	if not appr_ok then
		if #m_tech > 0 then
			return false, "insufficient_techs"
		else
			return false, "insufficient_resources"
		end
	end

	if try then return true end

	-- Remove old idea
	inv:remove_item(invlist, "ctw_resources:idea_"..idea_id)

	-- successful: remove references and issue permission letter
	for _,stack in ipairs(idea.references_required) do
		inv:remove_item(invlist, stack, false)
	end

	minetest.chat_send_player(pname, "The idea \""..idea.name.."\" was approved! "..
			"Proceed to your team space and post the approval letter on the team billboard to start inventing the technology!")

	local istack = ctw_resources.get_approval_letter_istack(idea_id, idea, team)
	local leftover = inv:add_item(invlist, istack)
	if not leftover:is_empty() then
		-- No free inventory space. Drop it.
		local player = minetest.get_player_by_name(pname)
		minetest.add_item(player:get_pos(), leftover)
	end

	ctw_resources.set_team_idea_state(idea_id, team, "approved", pname)
	return true
end

function ctw_resources.get_approval_letter_istack(idea_id, idea, team)
	local istack = ItemStack("ctw_resources:approval")
	local meta = istack:get_meta()
	meta:set_string("description", "Approval letter for \""..idea.name.."\" (issued for team "..team.name..")")
	meta:set_string("team", team.name)
	meta:set_string("idea_id", idea_id)
	return istack
end

minetest.register_craftitem("ctw_resources:approval", {
	description = "Approval letter (blank) (you hacker you)",
	inventory_image = "default_paper.png",
	groups = {ctw_approval = 1},
	_usage_hint = "Deliver this to your team billboard!",
})
