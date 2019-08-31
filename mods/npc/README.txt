 API DOCUMENTATION
===================

npc.registered_events[npc_name] = NPC_Event[] (array)

NPC_Event = {
		id = ""/nil,
		-- ^ Unique NPC_Event ID for linking answers
		dialogue = "Hello $PLAYER. Good luck on your mission!",
		-- ^ Text to say
		conditions = {
			-- Examples:
			{ func = function, item = "default:stick", weight = 2 },
			{ idea_id = "bar", dp_min = 1000 },
		}
		-- ^ Per table entry: AND-connected conditions
		-- Possible conditions: Each adds one weight point (except 'weight')
		--   'func':    Function to check 'function(player)'
		--     Return 'number' (weight) on success, nil on failure
		--   'item':    'ItemStack' that must be present in the player's inventory
		--   'dp_min':  minimal amount of Discovery Points
		--   'idea':    Conditional idea checking
		--     Example: '{ "idea_id", "<COMPARISON>", "<IdeaState>" }'
		--     COMPARISON types: (see 'IdeaState' string states)
		--       'eq': Equals
		--       'lt': Less than
		--       'gt': Greather than
		--   'tech':    Conditional technology checking
		--     Same as 'idea' above, see 'TechState' string state
		--   'weight':  Overall additional weight for this condition
		-- See also: 'npc.register_event_idea_approve'
		--   and 'npc.register_event_idea_discover'
		-- The dialogue with the highest weight will be displayed to the player
		
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
	-- 'def_e': (optional) '{ discovery = string, dp_min = number }'

npc.register_event_idea_approve(npc_name, idea_id, def_e)
	-- Approves the specified idea
	-- 'def_e': (optional) '{ discovery = string, dp_min = number }'

npc.register_event_from_tech(npc_name, dialogue, tech_id)
	-- Gives the team  technology if the requirements are met
	-- 'dialogue': string/nil: Text to say
	-- 'tech_id': From ctw_techologies (untested)

npc.get_event_by_id(id)
	-- ^ Searchs an unique NPC_Event by ID
