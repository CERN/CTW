local function get_team_or_nil(name, param)
	local team = teams.get_by_player(name)
	if param ~= "." then
		team = teams.get(param or "")
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

local function get_idea_year_approx(idea_def)
	local idea_year = 0
	for i, tech_id in ipairs(idea_def.technologies_gained) do
		local tech_def = ctw_technologies.get_technology(tech_id)
		idea_year = math.max(idea_year, tech_def.year)
	end
	return idea_year
end

-- Import possible states from ctw_resources
local idea_levels = ctw_resources.idea_states

local cmd_defs = {
--BEGIN COMMAND DEFINITIONS
books = function(name, params)
	local player = get_player_or_nil(name, params[1])
	local idea_id = (params[2] or "?nil"):lower()
	if not player then
		return false, "Unknown player: " .. params[1]
	end
	local idea = ctw_resources.get_idea_raw(idea_id)
	if not idea then
		return false, "Unknown idea: " .. idea_id
	end

	local inv = player:get_inventory()
	for _, stack in ipairs(idea.references_required) do
		if not inv:contains_item("main", stack) then
			inv:add_item("main", stack)
		end
	end
	return true, "Gave resources for idea " .. idea_id
end,

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

		if sign == "-" then
			-- No tech tree triggers available!
			ctw_technologies.set_team_tech_state(tech_id, team, "undiscovered")
		else
			ctw_technologies.gain_technology(tech_id, team)
		end
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

view = function(name, params)
	local team = get_team_or_nil(name, params[1])
	if not team then
		return false, "Unknown team: " .. params[1]
	end

	local idea_progress = {}
	for i, state in ipairs(idea_levels) do
		idea_progress[state] = {}
	end

	local ideas = ctw_resources._get_ideas() -- UNDOCUMENTED
	for idea_id, idea_def in pairs(ideas) do
		local idea_team = ctw_resources.get_team_idea_state(idea_id, team)
		local year = get_idea_year_approx(idea_def)
		local state = idea_team.state

		table.insert(idea_progress[state], {
			year = year,
			title = ("%s, Y%i"):format(idea_id, year)
		})
	end

	-- Sort
	for state, idea_defs in pairs(idea_progress) do
		table.sort(idea_defs, function(a, b) return a.title < b.title end)
		if state == "discovered" then
			-- newest first (progress)
			table.sort(idea_defs, function(a, b) return a.year > b.year end)
		else
			-- oldest first (possibly most relevant)
			table.sort(idea_defs, function(a, b) return a.year < b.year end)
		end
	end

	-- Build formspec
	local width = 4
	local fs = {
		"size[13,8]",
		"tablecolumns[text;text]"
	}
	local x = 0
	local y = 0
	for i, state in ipairs(idea_levels) do
		local fields = {}
		for j, idea in ipairs(idea_progress[state]) do
			table.insert(fields, idea.title)
		end
		fs[#fs + 1] = ("label[%f,%f;%s]"):format(x, y, state)
		fs[#fs + 1] = ("table[%f,%f;%f,3.4;state_%s;%s;0]")
			:format(x, y + 0.5, width, state, table.concat(fields, ","))
		x = x + width + 0.2
		if i % 3 == 0 then
			x = 0
			y = y + 4
		end
	end

	minetest.show_formspec(name, "cheatengine:none", table.concat(fs))
	return true
end,

wipe = function(name, params)
	local to_wipe = {}
	if params[1] == "all" then
		for i, team in pairs(teams.get_all()) do
			table.insert(to_wipe, team.name)
		end
	else
		local team = get_team_or_nil(name, params[1])
		if not team then
			return false, "Unknown team: " .. params[1]
		end
		to_wipe = { team.name }
	end
	local keep_fields = {
		"name", "display_name",
		"display_name_capitalized",
		"color", "color_hex"
	}
	for i, tname in ipairs(to_wipe) do
		local team = teams.get(tname)
		for k, v in ipairs(team) do
			if not table_index(keep_fields, k) then
				team[k] = nil -- Table reference
			end
		end
		team.points = 0
		teams.add_points(tname, 0) -- Trigger callbacks
	end

	return true, "Wiped data of following teams: " .. table.concat(to_wipe, ",")
end,

year = function(name, params)
	local team = get_team_or_nil(name, params[1])
	if not team then
		return false, "Unknown team: " .. params[1]
	end
	local dst_year = tonumber(params[2]) or 1980
	local n_found = 0

	local ideas = ctw_resources._get_ideas() -- UNDOCUMENTED
	for idea_id, idea_def in pairs(ideas) do
		local idea_year = get_idea_year_approx(idea_def)

		ctw_resources.set_team_idea_state(idea_id, team,
			idea_year > dst_year and "undiscovered" or "invented")
		n_found = n_found + 1
	end

	local techs = ctw_technologies._get_technologies() -- UNDOCUMENTED
	for tech_id, tech_def in pairs(techs) do
		ctw_technologies.set_team_tech_state(tech_id, team,
			tech_def.year >= dst_year and "undiscovered" or "gained")
		n_found = n_found + 1
	end
	year.set(dst_year + 1, team.name)
	return true, "Changed to year " .. dst_year .. ". Found " ..
		n_found .. " ideas and techs."
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
		for cfunc, _ in pairs(cmd_defs) do
			table.insert(cmds, cfunc)
		end
		return false, "Possible params: " .. table.concat(cmds, ", ")
	end
})