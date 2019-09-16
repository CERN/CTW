-- Craft The Web
-- references.lua: API for "reference" resources.

--[[
References are actually just items that can be gained in the progress of the game
There is only a registration function for them, which in turn calls "register_craftitem"
Every reference has the group "ctw_reference = 1"

reference item definition
def = {
	description = "Red Book",
	_ctw_longdesc = "This is a book that is red and contains interesting information",
	-- long description text to be shown in documentation. This is read by the doc formspec renderer.

    inventory_image = "ctw_resources_red_book.png",
    <any other item definition fields>
}

]]--

local function ref_info(itemstack, player, pointed_thing)
	local pname = player:get_player_name()
	local idef = minetest.registered_items[itemstack:get_name()]
	if idef._ctw_reference_id then
		ctw_resources.show_reference_form(pname, idef._ctw_reference_id)
	end
end

local reference_entries = {}

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

function ctw_resources.show_reference_form(pname, id)
	local ref = reference_entries[id]
	if not ref then
		return false
	end
	
	local form = "size["..FORM.WIDTH..","..FORM.HEIGHT.."]real_coordinates[]"
	
	form = form .. "vertlabel[0.15,0.5"
					..";R E F E R E N C E]";
	form = form .. "box[0,0;0.5,"..FORM.HEIGHT..";#00FF00]";
	
	
	form = form .. "label["
					..FORM.ENTRY_START_X..","..FORM.ENTRY_START_Y
					..";"..ref.name.."\n"..string.rep("=", #ref.name).."]";
	
	form = form .. doc.widgets.text(ref.description, FORM.ENTRY_START_X, FORM.ENTRY_START_Y + 1,
				FORM.ENTRY_WIDTH - 0.4, FORM.ENTRY_HEIGHT-1)
	
	-- show it
	minetest.show_formspec(pname, "ctw_resources:ref_"..id, form)
end

function ctw_resources.register_reference(id, itemdef)
	if not itemdef.groups then
		itemdef.groups = {}
	end
	itemdef.groups.ctw_reference = 1
	itemdef._ctw_reference_id = id
	itemdef.on_use = ref_info
	itemdef._usage_hint = "Left-click to show information"

	reference_entries[id] = {
		name = itemdef.description,
		description = itemdef._ctw_longdesc
	}

	minetest.register_craftitem(id, itemdef)
end
