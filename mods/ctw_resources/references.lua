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


function ctw_resources.show_reference_form(pname, id)
	local ref = reference_entries[id]
	if not ref then
		return false
	end

	local form = ctw_technologies.get_detail_formspec({
		bt1 = {
			catlabel = "",
			entries = {},
		},
		bt2 = {
			catlabel = "",
			entries = {},
		},
		bt3 = {
			catlabel = "",
			entries = {},
		},
		vert_text = "R E F E R E N C E",
		title = ref.name,
		text = ref.description,

	}, pname)

	-- show it
	minetest.show_formspec(pname, "ctw_resources:ref_"..id, form)
	return true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()

	local id = string.match(formname, "^ctw_resources:ref_(.+)$");
	if id then
		if fields.goto_back then
			ctw_technologies.form_returnstack_pop(pname)
		end

		if fields.quit then
			ctw_technologies.form_returnstack_clear(pname)
		end

	end

end)

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
