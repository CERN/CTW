
-- Sanity check to check the links actually exist
-- Sort out any problems before they occur in-game
-- The complexity of dialogues might be too high to troubleshoot them all
minetest.register_on_mods_loaded(function()
	local list = npc.registered_events

	-- Check dead IDs
	for h, npc_dialogues in ipairs(list) do
	for i, event in ipairs(npc_dialogues) do
		for j, list in ipairs(event.conditions) do
			for key, value in pairs(list) do
				if key == "idea" then
					assert(#value == 3, "NPC: invalid 'idea' condition" ..
						" in '" .. event.text .. "'")
				end
				if key == "tech" then
					assert(#value == 3, "NPC: invalid 'tech' condition" ..
						" in '" .. event.text .. "'")
				end
			end
		end
		for j, option in ipairs(event.options or {}) do
			if type(option.target) == "string" and
					not npc.get_event_by_id(option.target) then
				error("NPC: Unsatisfied action ID " .. option.target ..
						" in '" .. event.text .. "'.")
			end
		end
	end
	end

	-- Check invalid technology dependencies
	-- TODO
	assert(teams)
end)