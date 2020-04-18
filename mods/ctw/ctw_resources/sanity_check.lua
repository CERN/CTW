
-- Sanity check whether all references exist
minetest.register_on_mods_loaded(function()
	local count = 0
	for idea_id, idea_def in pairs(ctw_resources._get_ideas()) do
		assert(idea_def.description:find("\x1b(T@", 0, true),
			"Idea " .. idea_id .. " description is not translated.")

		for _, reference in ipairs(idea_def.references_required) do
			assert(ItemStack(reference):is_known(), "Unknown item: " .. reference)
		end
		count = count + 1
	end
	print("[ctw_resources] Registered " .. count .. " ideas")
end)