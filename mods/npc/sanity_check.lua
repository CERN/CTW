
-- Sanity check to check the links actually exist
minetest.register_on_mods_loaded(function()
	local list = npc.registered_events

	-- Check dead IDs
	for h, npc_dialogues in ipairs(list) do
	for i, event in ipairs(npc_dialogues) do
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
end)