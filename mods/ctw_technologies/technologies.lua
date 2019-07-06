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

local function init_default(tab, field, def)
	tab[field] = tab[field] or def
end
local function contains(tab, value)
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
		error("tech_form_builder: ID "..idea_id.." is unknown!")
	end
	
	local n_tech_lines = math.max(math.max(#tech.requires, #tech.enables), #tech.benefits)
	
	local tech_line_h = 1
	local desc_height = doc.FORMSPEC.ENTRY_HEIGHT - tech_line_h*n_tech_lines - 0.5
	local tech_start_y = doc.FORMSPEC.ENTRY_START_Y + desc_height
	local third_width = doc.FORMSPEC.ENTRY_WIDTH / 3
	
	local form = "label["
					..doc.FORMSPEC.ENTRY_START_X..","..doc.FORMSPEC.ENTRY_START_Y
					..";"..tech.name.."\n"..string.rep("=", #tech.name).."]";
	form = form .. doc.widgets.text(tech.description, doc.FORMSPEC.ENTRY_START_X, doc.FORMSPEC.ENTRY_START_Y + 1, doc.FORMSPEC.ENTRY_WIDTH - 0.4, desc_height-1)
	
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
		local tech = {name= techid} --TODO
		form_render_tech_entry(rn, "tr", tech.name, 0, "ctw_technologies_technology.png")
	end
	form = form .. "label["
					..(doc.FORMSPEC.ENTRY_START_X+third_width)..","..(tech_start_y+0.2)
					..";Technologies enabled:]";
	for rn, techid in ipairs(tech.enables) do
		local tech = {name= techid} --TODO
		form_render_tech_entry(rn, "te", tech.name, third_width, "ctw_technologies_technology.png")
	end
	form = form .. "label["
					..(doc.FORMSPEC.ENTRY_START_X+2*third_width)..","..(tech_start_y+0.2)
					..";Benefits:]";
	for rn, bene in ipairs(tech.benefits) do
		local iname = bene.label
		local itex = bene.image or "ctw_texture_missing.png"
		form_render_tech_entry(rn, "bf", iname, 2*third_width, itex)
	end
	
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
					doc.show_entry(pname, "ctw_technologies", techid)
				end
			end
			for rn, techid in ipairs(tech.enables) do
				if fields["goto_te_"..rn] then
					doc.show_entry(pname, "ctw_technologies", techid)
				end
			end
			for rn, ref in ipairs(tech.benefits) do
				if fields["goto_bf_"..rn] then
					logs("-!-technology benefits not implemented!")
				end
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

function ctw_technologies.finish_register_technologies()
	logs("Building the technology tree...")
	for techid, tech in pairs(technologies) do
		-- scan through technologies and find which techs have this as requirement
		for atechid, atech in pairs(technologies) do
			if contains(atech.requires, techid) then
				table.insert(tech.enables, atechid)
			end
		end
	end
	-- find parallel topological sorting of tree elements
	local c_queue = {}
	-- find roots
	for techid, tech in pairs(technologies) do
		-- scan through technologies and find which techs have this as requirement
		if #tech.requires == 0 then
			table.insert(c_queue, techid)
		end
	end
	-- for every queue item, add its descendants and add current level
	while #c_queue > 0 do
		local techid = c_queue[1]
		table.remove(c_queue, 1)
		local tech = technologies[techid]
		if tech.tree_level then
			error("Topological sorting tech tree failed at "..techid.." because it has already been placed in the tree! Check for cycles!")
		end
		-- get level as max of levels of nodes before
		local lvl = tech.min_tree_level or 0
		for _, atechid in ipairs(tech.requires) do
			local atech = technologies[atechid]
			if not atech.tree_level then
				error("Topological sorting tech tree failed at "..techid.." because dependency "..atechid.." has no tree_level set!")
			end
			lvl = math.max(lvl, atech.tree_level + 1)
		end
		logs("Tech Tree Sort: "..techid.." on level "..lvl)
		tech.tree_level = lvl
		
		-- add enables to the queue
		for _, atechid in ipairs(tech.enables) do
			if not contains(c_queue, atechid) then
				table.insert(c_queue, atechid)
			end
		end
	end
	logs("Building the technology tree done.")
	for techid, tech in pairs(technologies) do
		-- scan through technologies and find which techs have this as requirement
		if not tech.tree_level then
			minetest.log("warning", "[ctw_technologies] Technology "..techid.." is not included in the tree, is this a cycle?")
		end
	end
end
