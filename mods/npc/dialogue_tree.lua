
local S = minetest.get_translator("npc")

-- == THE PROGRAMMER == --

npc.register_npc("programmer", {
	infotext = S("Computer specialist"),
	textures = { "npc_skin_geopbyte.png" }
})

npc.register_event("programmer", {
	id = "test1",
	dialogue = S("$PLAYER: setting sgml to gained."),
	conditions = {
		{ idea = {"sgml", "gt", "undiscovered"} }
	}, 
	options = {
		{
			text = "Set to gained",
			target = function(player)
				local teamdef = teams.get_by_player(player)
				ctw_resources.set_team_idea_state("sgml", teamdef, "gained")
			end
		},
		{ text = "a", target = function() end },
		{ text = "ab", target = function() end },
		{ text = "ca", target = function() end },
		{ text = "bab", target = function() end },
	}
})

npc.register_event_idea_discover("programmer", "httpd", {})
npc.register_event_idea_approve("programmer", "httpd")


npc.register_npc("engineer", {
	infotext = S("Engineer"),
	textures = { "npc_skin_doctor_sam.png" }
})

npc.register_event("engineer", {
	dialogue = S("Hello $PLAYER. Good luck on your mission! Move tapes to gain DPs."),
})

npc.register_event_idea_discover("engineer", "ethernet", {
	dp_min = 2000,
	dialogue = S("Some kind of twisted cable thingy would be lovely.")
})