
-- Sanity check whether all benefits exist
minetest.register_on_mods_loaded(function()
	local count = 0
	for tech_id, tech_def in pairs(ctw_technologies._get_technologies()) do
		assert(tech_def.description:find("\x1b(T@", 0, true),
			"Tech " .. tech_id .. " description is not translated.")

		print(tech_id, dump(tech_def))
		ctw_technologies.check_benefits(tech_def.benefits)
		for _, benefit in ipairs(tech_def.benefits) do
			if benefit.type == "suppy" then
				-- Check whether the items exist
				for _, team_def in ipairs(teams.get_all()) do
					local stack = ItemStack(benefit.item:gsub("%%t", team_def.name))
					assert(stack:is_known(), "Unknown item: " ..
						stack:get_name() .. " in technology " .. tech_id)
				end
			end
		end

		count = count + 1
	end
	print("[ctw_technologies] Registered " .. count .. " technologies")
end)