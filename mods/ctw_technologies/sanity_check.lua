
-- Sanity check whether all benefits exist
minetest.register_on_mods_loaded(function()
	local count = 0
	for tech_id, tech_def in pairs(ctw_technologies._get_technologies()) do
		assert(tech_def.description:find("\x1b(T@", 0, true),
			"Tech " .. tech_id .. " description is not translated.")

		ctw_technologies.check_benefits(tech_def.benefits)
		count = count + 1
	end
	print("[ctw_technologies] Registered " .. count .. " technologies")
end)
