
-- Sanity check whether all references exist
minetest.register_on_mods_loaded(function()
	local count = 0
	for idea_id, idea_def in pairs(ctw_resources._get_ideas()) do
		local PFX = "Idea [" .. idea_id .. "]: "

		assert(idea_def.description:find("\x1b(T@", 0, true),
			PFX .. "Description is not translated.")
	
		-- Check whether the books are all available for this idea
		local year_max = 0
		for _, tech_id in ipairs(idea_def.technologies_required) do
			-- maximal year of required techs
			local tech_def = ctw_technologies.get_technology(tech_id)
			if #tech_def.requires > 0 then
				-- All but starting techs
				year_max = math.max(year_max, tech_def.year)
			end
		end
		if year_max == 0 then
			year_max = 1E9 -- No year requrement
		end

		for _, reference in ipairs(idea_def.references_required) do
			local stack = ItemStack(reference)
			assert(stack:is_known(), PFX .. "Unknown item: " .. reference)
			local def = stack:get_definition()
			assert((def._ctw_year or 0) < year_max, PFX .. "Cannot research. Book " ..
				reference .. " is not available in year " .. year_max)
		end
		count = count + 1
	end
	print("[ctw_resources] Registered " .. count .. " ideas")
end)