-- Craft The Web
-- Globalstep and API to invent technology (prototype ideas)

-- This function should be called by the team billboard once the approval letter is posted on it.
-- istack - the item stack of the approval letter
-- if "try" is true, will only perform a dry run and do nothing actually.
-- returns:
-- true - no error
-- false, error_reason - something went wrong
-- no_approval_letter - Passed item is not an approval letter
-- wrong_team - Approval letter was issued for another team
-- not_approved - Idea was not approved, letter is faked
-- already_invented - technology is already being invented.
function ctw_resources.start_inventing(istack, team, pname, try)
	if istack:get_name() ~= "ctw_resources:approval" then
		return false, "no_approval_letter"
	end
	local meta = istack:get_meta()
	local teamname_m = meta:get_string("team")
	local idea_id = meta:get_string("idea_id")

	local idea = ctw_resources.get_idea(idea_id)

	if teamname_m ~= team.name then
		return false, "wrong_team"
	end
	local istate = ctw_resources.get_team_idea_state(idea_id, team)
	if istate.state ~= "approved" then
		if istate.state == "inventing" or istate.state == "invented" then
			return false, "already_invented"
		else
			return false, "not_approved"
		end
	end

	if try then return true end

	local ready_score = 0

	-- ready, changing the state
	teams.chat_send_team(team.name, pname.." has gotten permission for prototyping \""..idea.name..
			"\". Your scientists will work hard! (you don't need to do anything)")
	ctw_resources.set_team_idea_state(idea_id, team, "inventing", ready_score)
	return true
end

-- Returns the state of all ideas a team is inventing, in this format:
-- [idea_id] = { progress = <in percent>, dp = <dp accumulated so far>, dp_total = <dp total required>}
function ctw_resources.get_inventing_progress(team)
	local prog = {}
	if team._ctw_resources_idea_state then
		for idea_id, istate in pairs(team._ctw_resources_idea_state) do
			local idea = ctw_resources.get_idea(idea_id)
			if istate.state == "inventing" then
				prog[idea_id] = {dp = istate.target, dp_total = idea.invention_dp}
			end
		end
	end
	return prog
end

local _register_on_inventing_progress = {}

-- func(team)
function ctw_resources.register_on_inventing_progress(func)
	table.insert(_register_on_inventing_progress, func)
end

local _register_on_inventing_complete = {}

-- func(team, idea_id)
function ctw_resources.register_on_inventing_complete(func)
	table.insert(_register_on_inventing_complete, func)
end

local function advance_inv_progress(ideas, delta_dp, team)

	if #ideas == 0 then
		return
	end

	local dp_share = delta_dp / #ideas

	for _, idea_id in ipairs(ideas) do
		local idea = ctw_resources.get_idea(idea_id)
		local istate = ctw_resources.get_team_idea_state(idea_id, team)

		istate.target = istate.target + dp_share

		if istate.target >= idea.invention_dp then
			-- The technology is invented.
			teams.chat_send_team(team.name, "Your scientists have successfully prototyped \""..idea.name.."\"!")
			for _, tech_id in ipairs(idea.technologies_gained) do
				ctw_technologies.gain_technology(tech_id, team)
			end
			ctw_resources.set_team_idea_state(idea_id, team, "invented")
			for i=1, #_register_on_inventing_progress do
				_register_on_inventing_complete[i](team, idea_id)
			end
		end
	end
	
	for i=1, #_register_on_inventing_progress do
		_register_on_inventing_progress[i](team)
	end
end

local prev_dp_by_team = {}

local timer = 3

minetest.register_globalstep(function(dtime)
	
	timer = timer - dtime
	if timer > 0 then return end
	timer = 2
	
	for _,team in ipairs(teams.get_all()) do
		if not prev_dp_by_team[team.name] then
			prev_dp_by_team[team.name] = team.points
		else
			local dp_delta = team.points - prev_dp_by_team[team.name]
			if dp_delta ~= 0 then
				prev_dp_by_team[team.name] = team.points
				local ideas_inventing = {}
				if team._ctw_resources_idea_state then
					for idea_id, istate in pairs(team._ctw_resources_idea_state) do
						if istate.state == "inventing" then
							table.insert(ideas_inventing, idea_id)
						end
					end
				end
				advance_inv_progress(ideas_inventing, dp_delta, team)
			end
		end
	end
end)
