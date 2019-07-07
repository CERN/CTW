 API DOCUMENTATION
===================

npc.registered_events[npc_name] = NPC_Event[] (array)

NPC_Event = {
		id = ""/nil,
		-- ^ Unique NPC_Event ID for linking answers
		dialogue = "Hello $PLAYER. Good luck on your mission!",
		-- ^ Text to say
		conditions = {
			{ func = function, item = "", weight = 2/nil },
			{ idea_id = "bar", dp_min = 10, weight = 2/nil },
		}
		-- ^ Per table entry: AND-connected conditions
		-- One condition table has to match entirely to be called
		-- 'func': Function to check 'function(player)'
		--   Return 'number' (weight) on success, nil on failure
		options = {
			{ text = "", target = "id"/function },
		}
		-- ^ Table containing possible answer options (bottons)
		-- 'text':   the displayed text
		-- 'target': an NPC_Event ID or custom 'function(player, NPC_Event)'
}

Special 'dialogue' fields:
	$PLAYER = Player name
	$TEAM = Team name


 FUNCTIONS
-----------
npc.register_npc(npc_name, def)
	-- ^ Registers an NPC.
	-- 'def': Regular entity scaling and texturing fields

npc.register_event(npc_name, NPC_Event)
	-- ^ 'dialogue' must be specified

npc.register_event_idea_discover(npc_name, idea_id, def_e)
	-- Gives the player a new idea
	-- 'def_e': (optional) 'NPC_Event' (only 'dialogue')

npc.register_event_idea_approve(npc_name, idea_id, def_e)
	-- Approves the specified idea
	-- 'def_e': (optional) 'NPC_Event' (only 'dialogue')

npc.register_event_from_idea(npc_name, dialogue, idea_id)
	-- Gives the team an idea if the requirements are met
	-- 'dialogue': string/nil: Text to say
	-- 'idea_id': From ctw_techologies (untested)

npc.register_event_from_tech(npc_name, dialogue, tech_id)
	-- Gives the team  technology if the requirements are met
	-- 'dialogue': string/nil: Text to say
	-- 'tech_id': From ctw_techologies (untested)

npc.get_event_by_id(id)
	-- ^ Searchs an unique NPC_Event by ID
