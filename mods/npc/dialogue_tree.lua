
local S = minetest.get_translator("npc")

--[[
npc.register_event("programmer", {
	id = "test1",
	dialogue = S("$PLAYER: setting sgml undoscovered -> gained."),
	conditions = {
		{ idea = {"sgml", "eq", "undiscovered"} }
	},
	options = {
		{
			text = "Set to gained",
			target = function(player)
				local teamdef = teams.get_by_player(player)
				ctw_resources.set_team_idea_state("sgml", teamdef, "gained")
			end
		},
		{ text = "option A", target = function() end },
		{ text = "option B", target = function() end },
	}
})
]]

local function register_both(...)
	local args = {...}
	npc.register_event_idea_discover(unpack(args))
	npc.register_event_idea_approve(unpack(args))
end

-- == THE NETWORK GURU == --

npc.register_npc("network_guru", {
	infotext = S("Mr. McNetworking Guru"),
	textures = { "npc_skin_geopbyte.png" }
})

register_both("network_guru", "e10base2")
register_both("network_guru", "ethernet")
register_both("network_guru", "fiberproduction")
register_both("network_guru", "twistethernet")
register_both("network_guru", "dynroutingrip")
register_both("network_guru", "fibercommunications")
register_both("network_guru", "cat5")
register_both("network_guru", "cidrrouting")
register_both("network_guru", "fastethernet")


-- == THE ENGINEER == --

npc.register_npc("engineer", {
	infotext = S("Dr. Jeff from ThinkCorporation"),
	textures = { "npc_skin_doctor_sam.png" }
})

-- Fallback
npc.register_event("engineer", {
	dialogue = S("Hello $PLAYER. Good luck on your mission! Move tapes to gain DPs."),
})

register_both("engineer", "tcpip")
register_both("engineer", "tokenring")
register_both("engineer", "gnu")
register_both("engineer", "dns")
register_both("engineer", "hypertext")
register_both("engineer", "dynroutingbgp")
register_both("engineer", "merger")
register_both("engineer", "hypertextproposal")
register_both("engineer", "http")
register_both("engineer", "html")
register_both("engineer", "cernbook")
register_both("engineer", "violawww")
register_both("engineer", "splitter")
register_both("engineer", "gnn")
register_both("engineer", "wwwpublic")
register_both("engineer", "mosaic")
register_both("engineer", "url")
register_both("engineer", "iexplore")
register_both("engineer", "w3c")

-- == THE PROGRAMMER == --

npc.register_npc("programmer", {
	infotext = S("Decked Programmer"),
	textures = { "npc_skin_geopbyte.png" }
})

register_both("programmer", "sgml")
register_both("programmer", "enquire")
register_both("programmer", "cerndoc")
register_both("programmer", "tangle")
register_both("programmer", "grif")
register_both("programmer", "enquire2")
register_both("programmer", "gif")
register_both("programmer", "enquire2")
register_both("programmer", "gpl")
register_both("programmer", "httpd")
register_both("programmer", "wwwbrowser")
register_both("programmer", "linux")
register_both("programmer", "cernpage")
register_both("programmer", "lynx")
register_both("programmer", "netscape")
register_both("programmer", "png")



--[[npc.register_event_idea_discover("engineer", "ethernet", {
	dp_min = 2000,
	dialogue = S("Some kind of twisted cable thingy would be lovely.")
})]]