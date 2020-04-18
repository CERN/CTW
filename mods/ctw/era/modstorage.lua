era.storage = minetest.get_mod_storage()
era.db = {}
local dbstring = era.storage:get_string("db")
if dbstring ~= "" then
	era.db = minetest.deserialize(dbstring)
end

era.db_commit = function()
	era.storage:set_string("db", minetest.serialize(era.db))
end
