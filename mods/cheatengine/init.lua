local function get_team_or_nil(name, param)
	local team = teams.get_by_player(name)
	if param ~= "." then
		team = teams.get(param)
	end
	return team
end

local function get_player_or_nil(name, param)
	local player = minetest.get_player_by_name(name)
	if param ~= "." then
		player = minetest.get_player_by_name(param)
	end
	return player
end

local function table_index(t, what)
	for k, v in pairs(t) do
		if v == what then
			return k
		end
	end
end

-- Import possible states from ctw_resources
local idea_levels = ctw_resources.idea_states

local cmd_defs = {
--BEGIN COMMAND DEFINITIONS
dp = function(name, params)
	local team = get_team_or_nil(name, params[1])
	local amount = tonumber(params[2])
	if not team then
		return false, "Unknown team: " .. params[1]
	end
	if not amount then
		return false, "Invalid amount"
	end

	local sign = params[2]:sub(1, 1)
	if sign ~= "+" and sign ~= "-" then
		-- Set points
		local points = teams.get_points(team.name)
		amount = -points + amount
	end
	local points = teams.add_points(team.name, amount)
	return true, "New points: " .. points
end,

team = function(name, params)
	local player = get_player_or_nil(name, params[1])
	local team = get_team_or_nil(name, params[2])
	if not player then
		return false, "Unknown player: " .. params[1]
	end
	if not team then
		return false, "Unknown team: " .. (params[2] or "?nil")
	end
	if teams.set_team(player, team.name) then
		return true, "Set team to: " .. team.name
	end
	return false, "Failed to set team"
end,

tech = function(name, params)
	local team = get_team_or_nil(name, params[1])
	if not team then
		return false, "Unknown team: " .. params[1]
	end

	local function process(i)
		local sign = params[i]:sub(1, 1)
		local tech_id = params[i]:sub(2)
		if not ctw_technologies.get_technology_raw(tech_id) then
			return
		end
		ctw_technologies.set_team_tech_state(tech_id, team,
			sign == "-" and "undiscovered" or "gained")
		return params[i]
	end

	local techs_ok = {}
	for i = 2, #params, 1 do
		local what = process(i)
		if what then
			table.insert(techs_ok, what)
		end
	end
	local ret = "Modified techs: " .. table.concat(techs_ok, ", ")
	if #techs_ok < #params - 1 then
		local text_available = {}
		for id, def in pairs(ctw_technologies._get_technologies()) do
			table.insert(text_available, id)
		end
		ret = ret .. "\nAvailable techs: " .. table.concat(text_available, ", ")
	end
	return true, ret
end,

idea = function(name, params)
	local team = get_team_or_nil(name, params[1])
	if not team then
		return false, "Unknown team: " .. params[1]
	end

	params[2] = params[2] or "?nil"
	local idea_id = params[2]:sub(2)
	if not ctw_resources.get_idea_raw(idea_id) then
		local text_available = {}
		for id, def in pairs(ctw_resources._get_ideas()) do
			table.insert(text_available, id)
		end
		return false, "Unknown idea: " .. params[2] ..
				"\nAvailable ideas: " .. table.concat(text_available, ", ")
	end

	local state_str = ctw_resources.get_team_idea_state(idea_id, team).state
	local sign = params[2]:sub(1, 1)
	print(dump(ctw_resources.get_team_idea_state(idea_id, team)))
	local state = table_index(idea_levels, state_str) or 0
	if sign == "+" then
		state = state + 1
	elseif sign == "-" then
		state = state - 1
	else
		return false, "Unknown modifier: " .. sign
	end
	local new_state = math.max(1, math.min(state, #idea_levels))
	state_str = idea_levels[new_state]
	if new_state ~= state then
		return false, "State unmodified: " .. state_str
	end
	ctw_resources.set_team_idea_state(idea_id, team, state_str,
		state_str == "inventing" and 1000 or name)
	return true, "State set to: " .. state_str
end,
-- END COMMAND DEFINITIONS
}


minetest.register_chatcommand("/", {
	privs = { server = true },
	func = function(name, text)
		local params = text:trim():split(" ")
		local func = cmd_defs[params[1]]
		if func and #params > 1 then
			table.remove(params, 1)
			return func(name, params)
		end
		local cmds = {}
		for func, _ in pairs(cmd_defs) do
			table.insert(cmds, func)
		end
		return false, "Possible params: " .. table.concat(cmds, ", ")
	end
})