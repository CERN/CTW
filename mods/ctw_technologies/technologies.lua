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
local function contains(tab, value) --luacheck: ignore
	for _,v in ipairs(tab) do
		if v==value then return true end
	end
	return false
end

local function logs(str)
	minetest.log("action", "[ctw_technologies] "..str)
end

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

function ctw_technologies.show_technology_form(pname, techid)
	local tech = technologies[techid]
	if not tech then
		return false
	end
	
	local team = teams.get_by_player(pname)
	local is_gained = false
	if team and ctw_technologies.is_tech_gained(techid, team) then
		is_gained = true
	end

	local n_tech_lines = math.max(math.max(#tech.requires, #tech.enables), #tech.benefits)

	local tech_line_h = 1
	local desc_height = FORM.ENTRY_HEIGHT - tech_line_h*n_tech_lines - 0.5
	local tech_start_y = FORM.ENTRY_START_Y + desc_height
	local third_width = FORM.ENTRY_WIDTH / 3

	local form = "size["..FORM.WIDTH..","..FORM.HEIGHT.."]real_coordinates[]"
	
	form = form .. "vertlabel[0.15,0.5"
					..";T E C H N O L O G Y]";
	form = form .. "box[0,0;0.5,"..FORM.HEIGHT..";#00FF00]";
	
	
	form = form .. "label["
					..FORM.ENTRY_START_X..","..FORM.ENTRY_START_Y
					..";"..tech.name.."\n"..string.rep("=", #tech.name).."]";
	
	if is_gained then
		form = form .. doc.widgets.text(tech.description, FORM.ENTRY_START_X, FORM.ENTRY_START_Y + 1,
				FORM.ENTRY_WIDTH - 0.4, desc_height-1)
	else
		form = form .. "label["
					..FORM.ENTRY_START_X..","..(FORM.ENTRY_START_Y+2)
					..";This technology is not yet discovered by your team.]";
	end

	local function form_render_tech_entry(rn, what, label, xstart, img)
		form = form .. "image_button["
						..(FORM.ENTRY_START_X+xstart)..","..(tech_start_y + rn*tech_line_h - 0.2)..";1,1;"
						..img..";"
						.."goto_"..what.."_"..rn..";"
						.."]"
		form = form .. "label["
					..(FORM.ENTRY_START_X+xstart+1)..","..(tech_start_y + rn*tech_line_h)
					..";"..label.."]";
	end

	form = form .. "label["
					..(FORM.ENTRY_START_X)..","..(tech_start_y+0.2)
					..";Technologies required:]";
	for rn, techid in ipairs(tech.requires) do
		local tech2 = ctw_technologies.get_technology(techid)
		form_render_tech_entry(rn, "tr", tech2.name, 0, "ctw_technologies_technology.png")
	end
	form = form .. "label["
					..(FORM.ENTRY_START_X+third_width)..","..(tech_start_y+0.2)
					..";Technologies enabled:]";
	for rn, techid in ipairs(tech.enables) do
		local tech2 = ctw_technologies.get_technology(techid)
		form_render_tech_entry(rn, "te", tech2.name, third_width, "ctw_technologies_technology.png")
	end
	form = form .. "label["
					..(FORM.ENTRY_START_X+2*third_width)..","..(tech_start_y+0.2)
					..";Benefits:]";
	for rn, bene in ipairs(tech.benefits) do
		local itex, iname = ctw_technologies.render_benefit(bene)
		form_render_tech_entry(rn, "bf", iname, 2*third_width, itex)
	end

	form = form .. "button["
				..(FORM.ENTRY_END_X-4.5)..","..(FORM.ENTRY_START_Y)..";4,1;"
				.."tech_tree;"
				.."<<< Technology tree]"

	-- show it
	minetest.show_formspec(pname, "ctw_technologies:entry_"..techid, form)
	return true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	
	local techid = string.match(formname, "^ctw_technologies:entry_(.+)$");
	if techid then
		local tech = technologies[techid]
		if not tech then
			return
		end
		for rn, techid in ipairs(tech.requires) do
			if fields["goto_tr_"..rn] then
				if technologies[techid] then
					ctw_technologies.show_technology_form(pname, techid)
				end
			end
		end
		for rn, techid in ipairs(tech.enables) do
			if fields["goto_te_"..rn] then
				if technologies[techid] then
					ctw_technologies.show_technology_form(pname, techid)
				end
			end
		end
		for rn, ref in ipairs(tech.benefits) do
			if fields["goto_bf_"..rn] then
				-- nothing happens
			end
		end
		if fields.tech_tree then
			ctw_technologies.show_tech_tree(pname, 0)
		end
	end

end)



function ctw_technologies.register_technology(id, tech_def)
	if technologies[id] then
		error("Tech with ID "..id.." is already registered!")
	end

	assert(type(tech_def.year) == "number", "Year value missing.")
	init_default(tech_def, "name", id)
	init_default(tech_def, "description", "No description")
	init_default(tech_def, "requires", {})
	init_default(tech_def, "enables", {})
	init_default(tech_def, "benefits", {})

	technologies[id] = tech_def
	logs("Registered Technology: "..id)
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
		else
			logs("-!- Benefits not implemented (in gain_technology)")
		end
	end
	return true
end

