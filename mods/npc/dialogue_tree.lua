
-- == THE PROGRAMMER == --

npc.register_npc("programmer", {
	infotext = "Computer specialist",
	textures = { "npc_skin_geopbyte.png" }
})

npc.register_event("programmer", {
	id = "test1",
	dialogue = "$PLAYER, line1\n\n\nlineX;:/\\]",
	options = {
		{
			text = "get",
			target = function(player, event)
				player:get_inventory():add_item("main", "default:stick")
			end
		},
		{ text = "a", target = function() end },
		{ text = "ab", target = function() end },
		{ text = "ca", target = function() end },
		{ text = "bab", target = function() end },
	}
})

npc.register_event_idea_discover("programmer", "ascii", {
	dialogue = "What if there was a standard for character encoding?"
})

npc.register_event_idea_approve("programmer", "ascii")

npc.register_npc("engineer", {
	infotext = "Engineer",
	textures = { "npc_skin_doctor_sam.png" }
})

npc.register_event("engineer", {
	dialogue = "Hello $PLAYER. Good luck on your mission! Move tapes to gain DPs.",
})
