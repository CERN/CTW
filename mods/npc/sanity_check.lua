
-- Sanity check to check the links actually exist
-- Sort out any problems before they occur in-game
-- The complexity of dialogues might be too high to troubleshoot them all
minetest.register_on_mods_loaded(function()
	-- Events for each registered npc
	for h, npc_events in ipairs(npc.registered_events) do
	-- Each registered event
	for i, event in ipairs(npc_events) do
		-- Check conditions
		for j, list2 in ipairs(event.conditions) do
			for key, value in pairs(list2) do
				if key == "item" then
					local stack = ItemStack(value)
					assert(minetest.registered_items[stack:get_name()],
						"NPC: item " .. stack:get_name() .. " used in '" ..
						event.text .. "' does not exist.")
				elseif key == "idea" then
					assert(#value == 3, "NPC: invalid 'idea' condition" ..
						" in '" .. event.text .. "'")
					ctw_resources.get_idea(value[3])
				elseif key == "tech" then
					assert(#value == 3, "NPC: invalid 'tech' condition" ..
						" in '" .. event.text .. "'")
					ctw_technologies.get_technology(value[3])
				end
			end
		end
		-- Check options (answer buttons)
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