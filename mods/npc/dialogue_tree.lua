
npc.register_npc("steve", {
	infotext = "Tutor",
	textures = { "npc_skin_doctor_sam.png" }
})

npc.register_event("steve", {
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

npc.register_event("steve", {
	id = "test2",
	dialogue = "Oh, that's some great literature you've got there!" ..
		"\nI'll call this one 'HTML'.",
	conditions = {
		{ idea_id = "html" }
	},
	options = {
		{
			text = "Thank you!",
			target = function(player, event)
				local teamdef = teams.get_by_player(player)
				local members = teams.get_members(teamdef.name)
				ctw_resources.reveal_idea("html", members)
			end
		}
	}
})


npc.register_event("steve", {
	dialogue = "Hello $PLAYER. Good luck on your mission! Move tapes to gain DPs.",
})
