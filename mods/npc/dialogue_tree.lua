
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

-- == THE PROGRAMMER == --

npc.register_npc("programmer", {
	infotext = S("Computer specialist"),
	textures = { "npc_skin_geopbyte.png" }
})

register_both("programmer", "sgml")
register_both("programmer", "enquire")
register_both("programmer", "gnu")
register_both("programmer", "sgml")
register_both("programmer", "cerndoc")


-- == THE ENGINEER == --

npc.register_npc("engineer", {
	infotext = S("Engineer"),
	textures = { "npc_skin_doctor_sam.png" }
})

-- Fallback
npc.register_event("engineer", {
	dialogue = S("Hello $PLAYER. Good luck on your mission! Move tapes to gain DPs."),
})

register_both("engineer", "e10base2")
register_both("engineer", "tcpip")
register_both("engineer", "ethernet")
register_both("engineer", "tokenring")

--[[npc.register_event_idea_discover("engineer", "ethernet", {
	dp_min = 2000,
	dialogue = S("Some kind of twisted cable thingy would be lovely.")
})]]