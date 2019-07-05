-- Craft The Web
-- ideas.lua: API for "idea" resources.

--[[
	An idea is a special item a team gets from NPCs or by other means.
	When a player gets an idea, it is available for the whole team once
	he returned to the team space. An Idea is an "instruction" how to get
	to a certain technology.
	An "idea" is referenced by a unique identifier.
	
	[idea] = {
		name = "ASCII",
		description = "It is necessary to create one unique standard for
			character encoding that every device complies to. ",
		technologies_gained = {
			[technology IDs],...
			-- List of technologies (=awards) the team will gain when
				getting permission for this idea.
		}
		technologies_required = {
			[technology IDs],...
			-- List of technologies the team needs to have discovered
				before this idea will work
		}
		references_required = {
			[ItemStack],...
			-- List of references (=books) required, as ItemStacks
			-- Be sure not to include one item name multiple times, this will lead to incorrect behavior!
		}
	}
	
	Documentation is automatically generated out of these data
]]

local ideas = {}

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
	minetest.log("action", "[ctw_resources] "..str)
end

local function idea_form_builder(id)
	local idea = ideas[id]
	if not idea then
		error("idea_form_builder: ID "..idea_id.." is unknown!")
	end
	
	local n_tech_lines = math.max(math.max(#idea.references_required, #idea.technologies_required), #idea.technologies_gained)
	
	local tech_line_h = 1
	local desc_height = doc.FORMSPEC.ENTRY_HEIGHT - tech_line_h*n_tech_lines - 0.5
	local tech_start_y = doc.FORMSPEC.ENTRY_START_Y + desc_height
	local third_width = doc.FORMSPEC.ENTRY_WIDTH / 3
	
	local form = "label["
					..doc.FORMSPEC.ENTRY_START_X..","..doc.FORMSPEC.ENTRY_START_Y
					..";"..idea.name.."\n"..string.rep("=", #idea.name).."]";
	form = form .. doc.widgets.text(idea.description, doc.FORMSPEC.ENTRY_START_X, doc.FORMSPEC.ENTRY_START_Y + 1, doc.FORMSPEC.ENTRY_WIDTH - 0.4, desc_height-1)
	
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
					..";Technologies gained:]";
	for rn, techid in ipairs(idea.technologies_gained) do
		local tech = {name= techid} --TODO
		form_render_tech_entry(rn, "tg", tech.name, 0, "ctw_technologies_technology.png")
	end
	form = form .. "label["
					..(doc.FORMSPEC.ENTRY_START_X+third_width)..","..(tech_start_y+0.2)
					..";Technologies required:]";
	for rn, techid in ipairs(idea.technologies_required) do
		local tech = {name= techid} --TODO
		form_render_tech_entry(rn, "tr", tech.name, third_width, "ctw_technologies_technology.png")
	end
	form = form .. "label["
					..(doc.FORMSPEC.ENTRY_START_X+2*third_width)..","..(tech_start_y+0.2)
					..";References required:]";
	for rn, ref in ipairs(idea.references_required) do
		local istack = ItemStack(ref)
		local idef = minetest.registered_items[istack:get_name()]
		local iname = idef and idef.description or "Unknown Item"
		local itex = idef and idef.inventory_image or "ctw_texture_missing.png"
		form_render_tech_entry(rn, "rr", iname, 2*third_width, itex)
	end
	
	return form
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	if formname == "doc:entry" then
		local cid, eid = doc.get_selection(pname)
		if cid == "ctw_ideas" then
			local idea = ideas[eid]
			if not idea then
				return
			end
			for rn, techid in ipairs(idea.technologies_gained) do
				if fields["goto_tg_"..rn] then
					doc.show_entry(pname, "ctw_technologies", techid)
				end
			end
			for rn, techid in ipairs(idea.technologies_required) do
				if fields["goto_tr_"..rn] then
					doc.show_entry(pname, "ctw_technologies", techid)
				end
			end
			for rn, ref in ipairs(idea.references_required) do
				if fields["goto_rr_"..rn] then
					local istack = ItemStack(ref)
					local idef = minetest.registered_items[istack:get_name()]
					local iid = idef and idef._ctw_reference_id
					if idd then
						doc.show_entry(pname, "ctw_references", iid)
					end
				end
			end
		end
	end

end)

doc.add_category("ctw_ideas", {
	name = "Ideas",
	description = "Ideas that your team gained",
	build_formspec = idea_form_builder
})

-- Registers a new idea with the given idea_def.
function ctw_resources.register_idea(id, idea_def)
	if ideas[id] then
		error("Idea with ID "..id.." is already registered!")
	end
	
	init_default(idea_def, "name", id)
	init_default(idea_def, "description", "No description")
	init_default(idea_def, "technologies_gained", {})
	init_default(idea_def, "technologies_required", {})
	init_default(idea_def, "references_required", {})
	
	doc.add_entry("ctw_ideas", id, {
		name = idea_def.name,
		data = id,
		hidden = true,
	})
	
	ideas[id] = idea_def
	logs("Registered Idea: "..id)
end

function ctw_resources.get_idea(idea_id)
	return ideas[idea_id]
end

-- Checks if the idea can be approved by the management, that is, permission
-- should be granted
--  techs_provided - list of technology IDs the team has achieved
--  refs_inv, refs_invlist - inventory (list) which contains the references
--  returns true when the technology is approved
--  returns false, technologies_missing, references_missing when the technology can not be approved
function ctw_resources.is_idea_approved(idea_id, techs_provided, refs_inv, refs_invlist)
	local idea = ideas[idea_id]
	if not idea then
		error("is_idea_approved: ID "..idea_id.." is unknown!")
	end
	local techs_m = {}
	local refs_m = {}
	-- check technologies
	for _,tech in ipairs(idea.technologies_required) do
		if not contains(techs_provided, tech) then
			table.insert(techs_m, tech)
		end
	end
	-- check references
	atdebug(refs_inv:get_lists())
	atdebug(refs_inv:get_list(refs_invlist))
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

function ctw_resources.reveal_idea(idea_id, team_members)
	local idea = ideas[idea_id]
	if not idea then
		error("reveal_idea: ID "..idea_id.." is unknown!")
	end
	for _,pname in ipairs(team_members) do
		doc.mark_entry_as_revealed(pname, "ctw_ideas", idea_id)
	end
end

function ctw_resources.take_idea_references(idea_id, refs_inv, refs_invlist, try_run)
	local idea = ideas[idea_id]
	if not idea then
		error("take_references: ID "..idea_id.." is unknown!")
	end
	for _,stack in ipairs(idea.references_required) do
		refs_inv:remove_item(refs_invlist, stack, false)
	end
end

-- TODO only for testing

minetest.register_chatcommand("ctwt", {
         param = "",
         description = "Reveal the hidden entry of the doc_example mod",
         privs = {},
         func = function(playername, params)
                ctw_resources.reveal_idea(params, {"singleplayer"})
                doc.show_category("singleplayer", "ctw_ideas")
        end,
})
