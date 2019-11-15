reseau.storage = minetest.get_mod_storage()
reseau.db = {}
local dbstring = reseau.storage:get_string("db")
if dbstring ~= "" then
	reseau.db = minetest.deserialize(dbstring)
end

reseau.db_commit = function()
	reseau.storage:set_string("db", minetest.serialize(reseau.db))
end
