-- Craft The Web
-- Technologies - technology tree and information

--[[
A technology is something you can invent. It brings the team some advantages,
like new network equipment, a higher DP income or access to new areas
A technology can be gained by getting a corresponding idea, collect necessary resources
and then apply for permission at the General Office (which is represented by an NPC).
Once permission is granted, a certain time elapses until the technology is successfully invented.

There is a technology tree, which tells in which order technologies can be invented. For a technology to
be invented, certain technologies need to be invented before.
]]

local technologies = {}
local _register_on_gain = {}

local function init_default(tab, field, def)
	tab[field] = tab[field] or def
end
local function table_index(tab, value)
	for k, v in ipairs(tab) do
		if v == value then
			return k
		end
	end
end

function ctw_technologies.show_technology_form(pname, id, from_nativation)
	local tech = ctw_technologies.get_technology(id)
	local idea = ctw_resources.get_idea(id)
	if not idea or not tech then
		return true
	end

	-- Back/forth buttons
	if not from_nativation then
		ctw_technologies.form_returnstack_push(pname, function()
			ctw_technologies.show_technology_form(pname, id, true)
		end)
	end

	local team = teams.get_by_player(pname)
	local is_visible = false
	local state_str = ctw_resources.idea_states[1]
	local progress = 0

	if team then
		local istate = ctw_resources.get_team_idea_state(id, team)
		state_str = istate.state
		if state_str == "discovered" then
			is_visible = istate.by == pname
		elseif state_str ~= "undiscovered" then
			is_visible = true
		end
		progress = table_index(ctw_resources.idea_states, state_str) or 1
		progress = (progress - 1) / (#ctw_resources.idea_states - 1)
	end

	local form = ctw_technologies.get_detail_formspec({
		progress = {
			text = state_str,
			value = progress
		},
		bt1 = {
			type = "technology",
			catlabel = "Technologies required:",
			prefix = "goto_tech_",
			entries = idea.technologies_required,
		},
		bt2 = {
			type = "reference",
			catlabel = "References required:",
			prefix = "goto_ref_",
			entries = idea.references_required,
		},
		bt3 = {
			type = "benefit",
			catlabel = "Benefits:",
			prefix = "goto_bf_",
			entries = tech.benefits,
		},
		vert_text = "T E C H N O L O G Y",
		title = idea.name,
		text = is_visible and idea.description or
			"This idea is not yet discovered by your team.",

		add_btn_name = "tech_tree", -- optional, additional extra button
		add_btn_label = "Technology tree",
	}, pname)
	-- show it
	minetest.show_formspec(pname, "ctw_technologies:technology_"..id, form)
	return true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()

	local techid = string.match(formname, "^ctw_technologies:technology_(.+)$")
	local tech = technologies[techid]
	if not tech then
		return
	end

	if fields.quit then
		ctw_technologies.form_returnstack_clear(pname)
		return
	end

	-- search links
	for field,_ in pairs(fields) do
		local tech_id = string.match(field, "^goto_tech_(.+)$");
		if tech_id then
			ctw_technologies.show_technology_form(pname, tech_id)
			return
		end

		local ref_id = string.match(field, "^goto_ref_(.+)$");
		if ref_id then
			ctw_resources.show_reference_form(pname, ref_id)
			return
		end
	end
	for rn, ref in ipairs(tech.benefits) do
		if fields["goto_bf_"..rn] then
			-- nothing happens
		end
	end
	if fields.tech_tree then
		ctw_technologies.show_tech_tree(pname, 0)
		return
	end

	if fields.goto_back then
		ctw_technologies.form_returnstack_move(pname, -1)
		return
	end

	if fields.goto_forth then
		ctw_technologies.form_returnstack_move(pname, 1)
		return
	end
end)


function ctw_technologies.register_technology(id, tech_def)
	if technologies[id] then
		error("Tech with ID "..id.." is already registered!")
	end

	assert(type(tech_def.year) == "number", "Year value missing.")
	init_default(tech_def, "name", id)
	assert(tech_def.description, "Missing description")
	init_default(tech_def, "requires", {})
	init_default(tech_def, "benefits", {})
	tech_def.enables = {} -- Used by the technology tree

	minetest.after(0.5, ctw_technologies.check_benefits, tech_def.benefits)

	technologies[id] = tech_def
end

function ctw_technologies.get_technology_raw(id)
	return technologies[id]
end

function ctw_technologies.get_technology(id)
	if not technologies[id] then
		error("Technology ID "..id.." is unknown!")
	end
	return technologies[id]
end

function ctw_technologies._get_technologies()
	return technologies
end


-- Returns 'TechState' for the specified team
function ctw_technologies.get_team_tech_state(id, team)
	if not team then
		return {state = "undiscovered"}
	end
	if not team._ctw_technologies_tech_state then
		team._ctw_technologies_tech_state = {}
	end
	local state = team._ctw_technologies_tech_state[id]
	if not state then
		return {state = "undiscovered"}
	end
	return state
end

-- Get whether technology is gained by a team
function ctw_technologies.is_tech_gained(id, team)
	return ctw_technologies.get_team_tech_state(id, team).state == "gained"
end

-- Set the state of a team technology.
function ctw_technologies.set_team_tech_state(id, team, state)
	if not team._ctw_technologies_tech_state then
		team._ctw_technologies_tech_state = {}
	end
	local tstate = {state = state}
	team._ctw_technologies_tech_state[id] = tstate
end

function ctw_technologies.register_on_gain(func)
	table.insert(_register_on_gain, func)
end

-- Make a team gain a technology. This notifies the team,
-- and applies the benefits.
-- if "try" is true, will only perform a dry run and do nothing actually.
-- returns true or false, error_reason
-- "already_gained" - Technology was already gained.
function ctw_technologies.gain_technology(tech_id, team, try)
	local tech = ctw_technologies.get_technology(tech_id)
	local tstate = ctw_technologies.get_team_tech_state(tech_id, team)

	if tstate.state == "gained" then
		return false, "already_gained"
	end

	if try then return true end

	teams.chat_send_team(team.name, "You gained the technology \""..tech.name.."\"!")
	ctw_technologies.set_team_tech_state(tech_id, team, "gained")

	for i=1, #_register_on_gain do
		_register_on_gain[i](tech, team)
	end

	for _, benefit in pairs(tech.benefits) do
		if benefit.type == "supply" then
			ctw_technologies.queue_delivery(team.name, benefit.item:gsub("%%t", team.name),
					math.random(benefit.time_min or 30, benefit.time_max or 200))
		end
	end
	return true
end
