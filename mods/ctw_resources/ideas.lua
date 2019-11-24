-- Craft The Web
-- ideas.lua: API for "idea" resources.

local ideas = {}

ctw_resources.idea_states = {
	"undiscovered",
	"discovered",
	"published",
	"approved",
	"inventing",
	"invented"
}

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

local function logs(str)
	minetest.log("action", "[ctw_resources] "..str)
end

minetest.after(0, function()
	local count = 0
	for k, v in pairs(ctw_resources._get_ideas()) do
		count = count + 1
	end
	logs("Registered " .. count .. " ideas")
end)

-- Formspec information
FORM = {}
-- Width of formspec
FORM.WIDTH = 15
FORM.HEIGHT = 10.5

--[[ Recommended bounding box coordinates for widgets to be placed in entry pages. Make sure
all entry widgets are completely inside these coordinates to avoid overlapping. ]]
FORM.ENTRY_START_X = 1
FORM.ENTRY_START_Y = 0.5
FORM.ENTRY_END_X = FORM.WIDTH
FORM.ENTRY_END_Y = FORM.HEIGHT - 0.5
FORM.ENTRY_WIDTH = FORM.ENTRY_END_X - FORM.ENTRY_START_X
FORM.ENTRY_HEIGHT = FORM.ENTRY_END_Y - FORM.ENTRY_START_Y

function ctw_resources.show_idea_form(pname, id)
	local idea = ideas[id]
	if not idea then
		return true
	end

	local team = teams.get_by_player(pname)
	local is_visible = false
	if team then
		local istate = ctw_resources.get_team_idea_state(id, team)
		if istate.state~="undiscovered" then
			if istate.state=="discovered" then
				is_visible = istate.by == pname
			else
				is_visible = true
			end
		end
	end

	local form = ctw_technologies.get_detail_formspec({
		bt1 = {
			catlabel = "Technologies required:",
			func = ctw_technologies.detail_formspec_bt_techfunc(team),
			entries = idea.technologies_required,
		},
		bt2 = {
			catlabel = "References required:",
			func = function(ref, idx)
				local istack = ItemStack(ref)
				local idef = minetest.registered_items[istack:get_name()]
				local iname = idef and idef.description or "Unknown Item"
				return "goto_ref_"..idef._ctw_reference_id,
					iname,
					istack:get_name(),
					istack:get_count()
			end,
			use_item_image_button=true,
			entries = idea.references_required,
		},
		bt3 = {
			catlabel = "Technologies unlocked:",
			func = ctw_technologies.detail_formspec_bt_techfunc(team),
			entries = idea.technologies_gained,
		},
		vert_text = "I D E A",
		title = idea.name,
		text = is_visible and idea.description,
		labeltext = "This idea is not yet discovered by your team.",
	}, pname)
	-- show it
	minetest.show_formspec(pname, "ctw_resources:idea_"..id, form)
	return true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()

	local id = string.match(formname, "^ctw_resources:idea_(.+)$");
	if id then
		local idea = ideas[id]
		if not idea then
			return
		end
		-- search links
		for field,_ in pairs(fields) do
			local tech_id = string.match(field, "^goto_tech_(.+)$");
			if tech_id and ctw_technologies._get_technologies()[tech_id] then
				ctw_technologies.form_returnstack_push(pname, function(pname) ctw_resources.show_idea_form(pname, id) end)
				ctw_technologies.show_technology_form(pname, tech_id)
				return
			end

			local ref_id = string.match(field, "^goto_ref_(.+)$");
			if ref_id then
				ctw_technologies.form_returnstack_push(pname, function(pname) ctw_resources.show_idea_form(pname, id) end)
				ctw_resources.show_reference_form(pname, ref_id)
				return
			end
		end

		if fields.goto_back then
			ctw_technologies.form_returnstack_pop(pname)
		end

		if fields.quit then
			ctw_technologies.form_returnstack_clear(pname)
		end

	end

end)

local function idea_info(itemstack, player, pointed_thing)
	local pname = player:get_player_name()
	local idef = minetest.registered_items[itemstack:get_name()]
	if idef._ctw_idea_id then
		ctw_resources.show_idea_form(pname, idef._ctw_idea_id)
	end
end

-- Registers a new idea with the given idea_def along with an item
function ctw_resources.register_idea(id, idea_def, itemdef_p)
	if ideas[id] then
		error("Idea with ID "..id.." is already registered!")
	end

	init_default(idea_def, "name", id)
	init_default(idea_def, "description", "No description")
	init_default(idea_def, "technologies_gained", {})
	init_default(idea_def, "references_required", {})


	-- Add parent technologies that are required in order to
	-- research this technology
	local idea_year = 0 -- approximated
	local techreq = {}
	for _, techid in ipairs(idea_def.technologies_gained) do
		local tech = ctw_technologies.get_technology(techid)
		idea_year = math.max(idea_year, tech.year)
		for _, atechid in ipairs(tech.requires) do
			if not table_index(techreq, atechid) then
				table.insert(techreq, atechid)
			end
		end
	end
	idea_def.technologies_required = techreq

	-- 49 * x² - 195 * x + 50 = DP
	-- 1980: 50 DP
	-- 1985: 300 DP
	-- 1990: 3'000 DP
	local delta = idea_year - 1980
	init_default(idea_def, "invention_dp", math.max(50,
		49 * delta^2 - 195 * delta + 50))

	-- register idea item
	local itemdef = {
		description = idea_def.name,
		inventory_image = "ctw_resources_idea_generic.png",
		groups = {},
		stack_max = 1,
		on_use = idea_info,
		_ctw_idea_id = id,
		_usage_hint = "Left-click to show information",
	}
	for k, v in pairs(itemdef_p or {}) do
		itemdef[k] = v
	end
	itemdef.groups.ctw_idea = 1
	minetest.register_craftitem("ctw_resources:idea_"..id, itemdef)

	ideas[id] = idea_def
end

function ctw_resources.register_idea_from_tech(tech_id, idea_def, itemdef_p)
	local tech = ctw_technologies.get_technology(tech_id)
	assert(idea_def.references_required, "Missing references table")
	local def = {
		name = tech.name,
		description = tech.description,
		technologies_gained = { tech_id }
	}
	for k, v in pairs(idea_def) do
		def[k] = v
	end
	ctw_resources.register_idea(tech_id, def, itemdef_p)
end


function ctw_resources.get_idea_raw(idea_id)
	return ideas[idea_id]
end

function ctw_resources.get_idea(idea_id)
	if not ideas[idea_id] then
		error("Idea ID "..idea_id.." is unknown!")
	end
	return ideas[idea_id]
end

function ctw_resources._get_ideas()
	return ideas
end

function ctw_resources.get_idea_from_istack(itemstack)
	local idef = minetest.registered_items[itemstack:get_name()]
	if idef._ctw_idea_id then
		return ideas[idef._ctw_idea_id]
	end
end

-- Give an idea to a player. The idea item will be issued into the
-- specified inventory
-- To be called from an NPC.
-- Returns true on success and false, error_reason on failure
-- if "try" is true, will only perform a dry run and do nothing actually.
-- error reasons: See README.txt
function ctw_resources.give_idea(idea_id, pname, inv, invlist, try)
	local idea = ctw_resources.get_idea(idea_id)

	--check if the player or the team already had the idea
	if inv:contains_item(invlist, "ctw_resources:idea_"..idea_id) then
		return false, "idea_present_in_player"
	end

	local team = teams.get_by_player(pname)
	if not team then return false, "no_team" end

	if ctw_resources.compare_idea(idea_id, team, "gt", "discovered") then
		return false, "idea_present_in_team"
	end

	-- For the case someone lost the idea item:
	local idea_team = ctw_resources.get_team_idea_state(idea_id, team)
	if idea_team.last_action and minetest.get_gametime() <
			idea_team.last_action + ctw_resources.LAST_ACTION_COOLDOWN then
		return false, "idea_present_in_team"
	end

	local n_gained = 0
	local idea_year = 0
	for i, tech_id in ipairs(idea.technologies_required) do
		local tech_def = ctw_technologies.get_technology(tech_id)
		local tech_state = ctw_technologies.get_team_tech_state(tech_id, team)
		if tech_state.state == "gained" then
			n_gained = n_gained + 1
		end
		idea_year = math.max(idea_year, tech_def.year)
	end
	if #idea.technologies_required - n_gained > 1 then
		return false, "not_enough_gained"
	end
	-- TODO: implement eras
	if idea_year > year.get(team) then
		return false, "era_not_reached"
	end

	local item = "ctw_resources:idea_"..idea_id
	if not inv:room_for_item(invlist, item) then
		return false, "no_space"
	end

	if try then return true end

	minetest.chat_send_player(pname, "You got an idea: "..idea.name..
			"! Proceed to your team space and share it on the team billboard!")

	local leftover = inv:add_item(invlist, item)
	if not leftover:is_empty() then
		-- No free inventory space. Drop it.
		local player = minetest.get_player_by_name(pname)
		minetest.add_item(player:get_pos(), leftover)
	end

	-- Note: if another player secretly had gotten this idea before, this will be overwritten.
	-- Should not cause side-effects.
	ctw_resources.set_team_idea_state(idea_id, team, "discovered", pname)
	return true
end

-- Publish the idea in the team
-- if "try" is true, will only perform a dry run and do nothing actually.
-- returns true or false, error_reason
-- "already_published" - Idea is published or in a later stage
function ctw_resources.publish_idea(idea_id, team, pname, try)
	local idea = ctw_resources.get_idea(idea_id)

	if ctw_resources.compare_idea(idea_id, team, "gt", "discovered") then
		return false, "already_published"
	end

	if try then
		return true
	end

	teams.chat_send_team(team.name, pname.." got an idea: \""..idea.name..
			"\". Go collect resources for it. You find the idea on the team billboard!")
	ctw_resources.set_team_idea_state(idea_id, team, "published")

	return true
end


-- Returns 'IdeaState' for the specified team
function ctw_resources.get_team_idea_state(idea_id, team)
	if not team._ctw_resources_idea_state then
		team._ctw_resources_idea_state = {}
	end
	local state = team._ctw_resources_idea_state[idea_id]
	if not state then
		return {state = "undiscovered"}
	end
	return state
end

-- Set the state of a team idea. param is either "by" or "finish" depending on situation
function ctw_resources.set_team_idea_state(idea_id, team, state, param)
	if not team._ctw_resources_idea_state then
		team._ctw_resources_idea_state = {}
	end
	local istate = {state = state}
	if state=="discovered" or state=="approved" then
		istate.by = param
		-- Add cooldown timestamp
		istate.last_action = minetest.get_gametime()
	elseif state=="inventing" then
		istate.target = param
	end
	team._ctw_resources_idea_state[idea_id] = istate

end

-- compare_idea(team, "eq", "discovered")
function ctw_resources.compare_idea(idea, team, cmp, value)
	local idea_state = type(idea) == "table" and idea.state or
		ctw_resources.get_team_idea_state(idea, team).state

	if cmp == "eq" then
		return idea_state == value
	end

	local index_1 = table_index(ctw_resources.idea_states, idea_state)
	local index_2 = table_index(ctw_resources.idea_states, value)
	assert(index_1, "Invalid idea state 1 '" .. tostring(idea_state) .. "'")
	assert(index_2, "Invalid idea state 2 '" .. tostring(value) .. "'")
	if cmp == "lt" then
		return index_1 < index_2
	end
	if cmp == "gt" then
		return index_1 > index_2
	end
	error("Invalid comparison: " .. cmp)
end

function ctw_resources.compare_all_ideas(team, cmp, value)
	local index_2 = table_index(ctw_resources.idea_states, value)
	assert(index_2, "Invalid idea state 2 '" .. tostring(value) .. "'")

	local ideas = {}
	local count = 0
	for idea_id, istate in pairs(team._ctw_resources_idea_state or {}) do
		local index_1 = table_index(ctw_resources.idea_states, istate.state)
		local ok = false
		if cmp == "eq" then
			ok = index_1 == index_2
		elseif cmp == "lt" then
			ok = index_1 < index_2
		elseif cmp == "gt" then
			ok = index_2 > index_2
		else
			error("Invalid comparison: " .. cmp)
		end
		if ok then
			ideas[idea_id] = istate
			count = count + 1
		end
	end
	return ideas, count
end
