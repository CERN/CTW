 TECHNOLOGY API
================

A technology is something you can invent. It brings the team some advantages,
like new network equipment, a higher DP income or access to new areas
A technology can be gained by getting a corresponding idea, collect necessary resources
and then apply for permission at the General Office (which is represented by an NPC).
Once permission is granted, a certain time elapses until the technology is successfully invented.

There is a technology tree, which tells in which order technologies can be invented. For a technology to
be invented, certain technologies need to be invented before.

After all tech registrations are complete, some fields are auto-generated (such as children)



 Technology Definition
-----------------------
The provided data is used to generate the documentation.

After all tech registrations are complete, some fields are auto-generated (such as children)
TechDef = {
	name = "World Wide Web",
	description = "A network of interconnected devices where all kinds of information are easily accessible.",
	requires = {
		"html",
		"lan",
	} -- Technologies that need to be invented before

	benefits = { BenefitDef, ... }
	-- See 'BenefitDef'

	min_tree_level = <n>
	-- Optional, if specified tells the minimum level at which this element will be
	-- positioned in the tree. Defaults to 0

	tree_line = <n>
	-- Optional, on which line to place the node

	tree_conn_loc = <llvl>
	-- optional, between which nodes to place the bend

	-- Those fields are filled in after registration automatically:
	enables = {
		-- Technologies that are now possible
	}
	tree_level = <n>
	-- Level on the technology tree where this tree element is drawn. Determined
	-- by a topological sort. Do never specify this manually
}
Documentation (doc mod) is automatically generated from TechDef.

TechState = {
	state = string,
	-- "undiscovered" Technology is not invented
	-- "gained"       Idea has been prototyped and technology has been gained.
}

BenefitDef = {
	-- List of benefits that this technology gives the team.
	-- The examples below contain a 'BenefitDef' each

 	type = "supply", item="reseau:splitter_%t", time_min=80, time_max=180,
	-- For palettes mod: Automatic spawning of items.
	-- 'item': 'ItemStack' to spawn. "%t" is substituted by the team name
	-- 'time_min': Minimal delay in seconds between spawning
	-- 'time_max': Maximal delay between spawning

	-- Integrated "multiplier" benefit types: (see reseau)
	type = "cable_throughput_multiplier",       value = 2,
	type = "receiver_throughput_multiplier",    value = 2,
	type = "transmitter_throughput_multiplier", value = 2,

	type="victory",
	-- Win condition
}

BenefitCalc = {
	accumulator = func(list)
	-- 'list': 'BenefitDef[]', list of all technology-unlocked benefits
	-- Return: The final output for all benefits ('number', 'string')
	renderer = func(bene)
	-- 'bene': 'BenefitDef', a bebefit to render (for docs)
	-- Return: 'string', text for the formspec element
}


 Technology API
----------------

ctw_technologies.get_technology(tech_id)
	-- Returns 'TechDef' or nil

ctw_technologies.is_tech_gained(tech_id, team)
	-- Returns: 'true' when state is gained

ctw_technologies.get_team_tech_state(tech_id, team)
	-- Get the state of a team technology.
	-- 'team': 'Team def'
	-- Returns: 'TechState'

ctw_technologies.set_team_tech_state(tech_id, team, state)
	-- Set the state of a team technology.
	-- 'team': 'Team def'
	-- 'state': see 'state' in 'TechState'

ctw_technologies.register_on_gain(func(tech_def, team))
	-- func() return value is ignored.

ctw_technologies.gain_technology(tech_id, team, try)
	-- Make a team gain a technology. This notifies the team, reveals the
	-- technology doc pages and applies the benefits.
	-- 'team': 'Team def'
	-- 'try': if 'true': will only perform a dry run (changes nothing)

ctw_technologies.update_doc_reveals(team)
	-- Updates the technology documentation pages
	-- Is called automatically on state changes
	-- 'team': 'Team def'

 Benefits API
--------------

Technologies can improve certain properties such as cable speed or capacity.

ctw_technologies.register_benefit_type(type, def)
	-- 'type': 'string', 'BenefitDef.type'
	-- 'def': 'BenefitCalc'

ctw_technologies.get_team_benefit(team, type, explicit_update)
	-- 'team': 'Team def' (see "teams" documentation)
	-- 'type': 'string', 'BenefitDef.type'
	-- 'explicit_update': optional. If 'true': Updates the benefit cache
	-- Returns: accumulated benefit by 'BenefitCalc.accumulator'

ctw_technologies.update_team_benefits(team)
	-- Manually updates the benefit cache
	-- 'team': 'Team def'

ctw_technologies.accumulate_benefits(type, list)
	-- Manually updates a single benefit type's cache
	-- 'type': 'string', 'BenefitDef.type'
	-- 'list': 'BenefitDef[]', list of benefits to pass to the accumulator


 Graphical Tree API
--------------------

ctw_technologies.build_tech_tree()
	-- Prepares rendering the technology tree

ctw_technologies.render_tech_tree(minpx, minpy, wwidth, wheight, scrollpos, discovered_techs, hilit)
	-- Does some black magic things. No touchy

ctw_technologies.show_tech_tree(pname, scrollpos)
	-- Shows up the technology tree formspec
	-- 'pname': Player name
	-- 'scrollpos': Scrollbar position value '0' to '1000'

ctw_technologies.render_benefit(bene)
	-- Looks up the assigned benefit texture and description
	-- 'bene': 'BenefitDef'
	-- Returns:
	--   texture     Texture name to display
	--   description Text for the description
