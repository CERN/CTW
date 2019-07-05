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


ctw_resources.register_reference(id, itemdef)
	if not itemdef.groups then
		itemdef.groups = {}
	end
	itemdef.groups.ctw_reference = 1
	
	minetest.register_craftitem("ctw_resources:"..id, itemdef)
end
