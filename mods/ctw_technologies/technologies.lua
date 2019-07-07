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

After all tech registrations are complete, some fields are auto-generated (such as children)

["www"] = {
		name = "World Wide Web",
		description = "A network of interconnected devices where all kinds of information are easily accessible.",
		requires = {
			"html",
			"lan",
		} -- Technologies that need to be invented before
		benefits = {
			<benefit definition>
			-- List of benefits that this technology gives the team. Implementation details are not clear yet.
			-- At the moment for testing purposes:
			{ image = "", label = ""}
		}

		min_tree_level = <n>
		-- Optional, if specified tells the minimum level at which this element will be
		-- positioned in the tree. Defaults to 0

		tree_line = <n>
		-- Optional, on which line to place the node

		tree_conn_loc = <llvl>
		-- optional, between which nodes to place the bend

		-- Those fields are filled in after registration automatically:
		enables = {
			-- Technologies that are now possible
		}
		tree_level = <n>
		-- Level on the technology tree where this tree element is drawn. Determined
		-- by a topological sort. Do never specify this manually
	}

	Documentation is automatically generated out of these data

]]--

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

local function tech_form_builder(id)
	local tech = technologies[id]
	if not tech then
		error("tech_form_builder: ID "..id.." is unknown!")
	end

	local n_tech_lines = math.max(math.max(#tech.requires, #tech.enables), #tech.benefits)

	local tech_line_h = 1
	local desc_height = doc.FORMSPEC.ENTRY_HEIGHT - tech_line_h*n_tech_lines - 0.5
	local tech_start_y = doc.FORMSPEC.ENTRY_START_Y + desc_height
	local third_width = doc.FORMSPEC.ENTRY_WIDTH / 3

	local form = "label["
					..doc.FORMSPEC.ENTRY_START_X..","..doc.FORMSPEC.ENTRY_START_Y
					..";"..tech.name.."\n"..string.rep("=", #tech.name).."]";
	form = form .. doc.widgets.text(tech.description, doc.FORMSPEC.ENTRY_START_X, doc.FORMSPEC.ENTRY_START_Y + 1,
			doc.FORMSPEC.ENTRY_WIDTH - 0.4, desc_height-1)

	local function form_render_tech_entry(rn, what, label, xstart, img)
		form = form .. "image_button["
						..(doc.FORMSPEC.ENTRY_START_X+xstart)..","..(tech_start_y + rn*tech_line_h - 0.2)..";1,1;"
						..img..";"
						.."goto_"..what.."_"..rn..";"
						.."]"
		form = form .. "label["
					..(doc.FORMSPEC.ENTRY_START_X+xstart+1)..","..(tech_start_y + rn*tech_line_h)
					..";"..label.."]";
	end

	form = form .. "label["
					..(doc.FORMSPEC.ENTRY_START_X)..","..(tech_start_y+0.2)
					..";Technologies required:]";
	for rn, techid in ipairs(tech.requires) do
		local tech2 = ctw_technologies.get_technology(techid)
		form_render_tech_entry(rn, "tr", tech2.name, 0, "ctw_technologies_technology.png")
	end
	form = form .. "label["
					..(doc.FORMSPEC.ENTRY_START_X+third_width)..","..(tech_start_y+0.2)
					..";Technologies enabled:]";
	for rn, techid in ipairs(tech.enables) do
		local tech2 = ctw_technologies.get_technology(techid)
		form_render_tech_entry(rn, "te", tech2.name, third_width, "ctw_technologies_technology.png")
	end
	form = form .. "label["
					..(doc.FORMSPEC.ENTRY_START_X+2*third_width)..","..(tech_start_y+0.2)
					..";Benefits:]";
	for rn, bene in ipairs(tech.benefits) do
		local itex, iname = ctw_technologies.render_benefit(bene)
		form_render_tech_entry(rn, "bf", iname, 2*third_width, itex)
	end

	form = form .. "button["
				..(doc.FORMSPEC.ENTRY_END_X-4)..","..(doc.FORMSPEC.ENTRY_START_Y)..";4,1;"
				.."tech_tree;"
				.."View technology tree]"

	return form
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	if formname == "doc:entry" then
		local cid, eid = doc.get_selection(pname)
		if cid == "ctw_technologies" then
			local tech = technologies[eid]
			if not tech then
				return
			end
			for rn, techid in ipairs(tech.requires) do
				if fields["goto_tr_"..rn] then
					if doc.entry_revealed(pname, "ctw_technologies", techid) then
						doc.show_entry(pname, "ctw_technologies", techid)
					end
				end
			end
			for rn, techid in ipairs(tech.enables) do
				if fields["goto_te_"..rn] then
					if doc.entry_revealed(pname, "ctw_technologies", techid) then
						doc.show_entry(pname, "ctw_technologies", techid)
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
	end

end)

doc.add_category("ctw_technologies", {
	name = "Technologies",
	description = "Technologies that your team has invented",
	build_formspec = tech_form_builder
})

function ctw_technologies.register_technology(id, tech_def)
	if technologies[id] then
		error("Tech with ID "..id.." is already registered!")
	end

	init_default(tech_def, "name", id)
	init_default(tech_def, "description", "No description")
	init_default(tech_def, "requires", {})
	init_default(tech_def, "enables", {})
	init_default(tech_def, "benefits", {})

	doc.add_entry("ctw_technologies", id, {
		name = tech_def.name,
		data = id,
		hidden = true,
	})

	technologies[id] = tech_def
	logs("Registered Technology: "..id)
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


-- Get the state of a team technology. This returns a table
-- {state = "undiscovered"} - Technology is not invented
-- {state = "gained"} - Idea has been prototyped and technology has been gained.
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

	ctw_technologies.update_doc_reveals(team)
end

function ctw_technologies.register_on_gain(func)
	table.insert(_register_on_gain, func)
end

-- Make a team gain a technology. This notifies the team, reveals the technology doc pages
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

function ctw_technologies.update_doc_reveals(team)
	for tech_id, tech in pairs(technologies) do
		local tstate = ctw_technologies.get_team_tech_state(tech_id, team)
		for _,player in ipairs(teams.get_online_members(team.name)) do
			if tstate.state ~= "undiscovered" then
				doc.mark_entry_as_revealed(player:get_player_name(), "ctw_technologies", tech_id)
			end
		end
	end
end

minetest.register_on_joinplayer(function(player)
	local team = teams.get_by_player(player:get_player_name())
	if team then
		ctw_technologies.update_doc_reveals(team)
	end
end)
