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
		doc.show_entry(pname, "ctw_references", idef._ctw_reference_id)
	end
end

doc.add_category("ctw_references", {
	name = "References",
	description = "References you can collect",
	build_formspec = doc.entry_builders.text,
})

function ctw_resources.register_reference(id, itemdef)
	if not itemdef.groups then
		itemdef.groups = {}
	end
	itemdef.groups.ctw_reference = 1
	itemdef._ctw_reference_id = id
	itemdef.on_use = ref_info
	itemdef._usage_hint = "Left-click to show information"

	doc.add_entry("ctw_references", id, {
		name = itemdef.description,
		data = "\n"..itemdef.description.."\n"..string.rep("=", #itemdef.description).."\n\n"..itemdef._ctw_longdesc,
	})

	minetest.register_craftitem(id, itemdef)
end
