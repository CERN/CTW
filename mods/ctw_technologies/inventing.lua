-- Craft The Web
-- Globalstep and API to invent technology (prototype ideas)

local c_time

-- This function should be called by the team billboard once the approval letter is posted on it.
-- istack - the item stack of the approval letter
-- returns:
-- true - no error
-- false, error_reason - something went wrong
-- wrong_team - Approval letter was issued for another team
-- not_approved - Idea was not approved, letter is faked, or technology is already being invented.
function ctw_resources.start_inventing(istack, team, pname)
	local meta = istack:get_meta()
	local teamname_m = meta:get_string("team")
	local idea_id = meta:get_string("idea_id")
	
	local idea = ctw_resources.get_idea(idea_id)
	
	if teamname_m ~= team.name then
		return false, "wrong_team"
	end
	local istate = ctw_resources.get_team_idea_state(idea_id, team)
	if istate.state ~= "approved" then
		return false, "not_approved"
	end
	
	local ready_score = team.points + idea.invention_dp
	
	-- ready, changing the state
	teams.chat_send_team(team.name, pname.." has gotten permission for prototyping \""..idea.name.."\". Your scientists will work hard! (you don't need to do anything)")
	ctw_resources.set_team_idea_state(idea_id, team, "inventing", ready_score)
end

minetest.register_globalstep(function(dtime)
	for _,tname in ipairs(teams.get_all()) do
		local team = teams.get(tname)
		if team.ctw_resources_idea_state then
			for idea_id, istate in pairs(team.ctw_resources_idea_state) do
				local idea = ctw_resources.get_idea(idea_id)
				if istate.state == "inventing" then
					if team.points >= istate.target then
						-- The technology is invented.
						teams.chat_send_team(tname, "Your scientists have successfully prototyped \""..idea.name.."\"!")
						for _, tech_id in ipairs(idea.technologies_gained) do
							ctw_technologies.gain_technology(tech_id, team)
						end
						ctw_resources.set_team_idea_state(idea_id, team, "invented")
					end
				end
			end
		end
	end
end)

