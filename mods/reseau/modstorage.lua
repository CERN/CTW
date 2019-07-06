reseau.storage = minetest.get_mod_storage()
reseau.db = {}
local dbstring = reseau.storage:get_string("db")
if dbstring ~= "" then
	reseau.db = minetest.deserialize(dbstring)
end

print("reseau.db: " .. dump(reseau.db))

reseau.db_commit = function(key, value)
	print("reseau.db: " .. dump(reseau.db))
	reseau.storage:set_string("db", minetest.serialize(reseau.db))
end
