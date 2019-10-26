 IDEA API
==========

An idea is a special item a team gets from NPCs or by other means.
When a player gets an idea, it is available for the whole team once
he returned to the team space. An Idea is an "instruction" how to get
to a certain technology.
An "idea" is referenced by a unique identifier.



 Idea Definition
-----------------
The provided data is used to generate the documentation.

IdeaDef = {
	name = "ASCII",
	description = "It is necessary to create one unique standard for
		character encoding that every device complies to. ",
	technologies_gained = {
		[tech_id],...
		-- List of technologies (=awards) the team will gain when
			getting permission for this idea.
	}
	references_required = {
		[ItemStack],...
		-- List of references (=books) required, as ItemStacks
		-- Be sure not to include one item name multiple times, this will lead to incorrect behavior!
	}
	dp_required = 1000
	-- Number of Discovery Points that are required to get this idea.
	-- This is just an orientational value when NPCs should give out the idea
	invention_dp = 1200
	-- DP which must be gained to invent the technology
	-- When starting invention, the current DP value is saved, technology will be finished when
	-- the score goes over DP+invention_dp.

	-- This field will be added automatically at registration based on the
	-- 'TechDef' reqirements of those specified in 'technologies_gained'
	technologies_required = {
		[technology IDs],...
	}
}
Documentation (doc mod) is automatically generated from ItemDef.

IdeaState = {
	state = string,
	-- "undiscovered" Not discovered yet
	-- "discovered"   Discovered by a team member but not on team billboard
    -- "published"    Discovered and published on team billboard
	-- "approved"     Idea is approved, but prototyping has not started yet
	-- "inventing"    Idea is being prototyped
	-- "invented"     Protoyping completed and technologies have been gained

	last_action = 0,
	-- Game timestamp (world), in seconds of the last idea interaction
	-- Ideas and approval letters will only be given out in a certain interval

	by = "playername",
	-- 'string' triggering player name
	-- Included in states "discovered", "approved" and "inventing"

	target = 1234
	-- 'number' of final DPs to complete prototyping (state = "inventing")
}


 Idea API
----------

ctw_resources.idea_states = {}
	-- Table listing all idea state strings from 'IdeaState'

ctw_resources.register_idea(idea_id, idea_def, itemdef_p)
	-- Registers an idea and a craftitem for it
	-- 'idea_id': string, unique identifier
	-- 'idea_def': 'IdeaDef'
	-- 'itemdef_p': (optional) 'ItemDef' for custom item definition fields

ctw_resources.register_idea_from_tech(tech_id, idea_def, itemdef_p)
	-- Registers an idea based on the technology ID.
	-- 'tech_id': string, existing technology ID
	-- 'itemdef_p': (optional)
	-- Values are passed to 'ctw_resources.register_idea'

ctw_resources.get_idea(idea_id)
	-- Returns: 'IdeaDef'

ctw_resources.get_idea_from_istack(itemstack)
	-- 'itemstack': 'ItemStack' of an idea craftitem
	-- Returns: 'IdeaDef' or nil

ctw_resources.give_idea(idea_id, pname, inventory, invlist)
	-- Give an idea to a player. The idea item will be issued into the
	-- specified inventory
	-- To be called from an NPC.
	-- Return values:
	--   true: success
	--   false, error_reason: failure
	--     "idea_present_in_player" Player already has this idea in inventory
	--     "idea_present_in_team"   Idea is already posted on the team billboard
	--     "no_space"               No free space in inventory
	--     "no_team"                Player has no team

ctw_resources.compare_idea(idea_id, team, cmp, value)
	-- Compare an idea state with the given value
	-- 'team': Team def'
	-- 'cmp': string, one of 'eq', 'lt' or 'gt'
	-- 'value: string, 'state' from 'IdeaState'
	-- Returns whether the comparison applies.


 Approving API
---------------

ctw_resources.is_idea_approved(idea_id, team, refs_inv, refs_invlist)
	-- Checks whether the idea can be approved by the management
	-- If so: Permission should be granted
	-- 'team': 'Team def'
	-- 'refs_inv': 'InvRef' of the player
	-- 'refs_invlist': 'string', inventory list name
	-- Return values:
	--   true: technology is approved
	--   false, technologies_missing, references_missing: cannot be approved
	--     *_missing: string table of missing parts

ctw_resources.approve_idea(idea_id, pname, inv, invlist, try)
	-- Approves an idea for the given player's team
	-- Get a permission letter for the passed idea, directed at the given team
	-- 'pname': 'ObjectRef' player applying for permission
	-- 'try': if 'true': will only perform a dry run (changes nothing)
	-- Returns:
	--   true: success
	--   false, error_reason: failure
	--     "already_approved"       Idea is already approved (approval letter already issued)
	--     "no_team"                Player has no team
	--     "insufficient_resources" Player has not brought enough resources
	--     "insufficient_techs"     One or more required technologies are not discovered yet

ctw_resources.publish_idea(idea_id, team, pname)
	-- Publish the idea in the team
	-- Return values:
	--   true
	--   false, error_reason
	--     "already_published" Idea is published or in a later stage

ctw_resources.get_team_idea_state(idea_id, team)
	-- Get the state of a team idea
	-- Return value: 'IdeaState'

ctw_resources.set_team_idea_state(idea_id, team, state, param)
	-- Set the state of a team idea
	-- 'team': 'Team def'
	-- 'state': 'state' from 'IdeaState'
	-- 'param': 'string'/'number'/nil value to assign to 'by' or 'target'
	--    See 'IdeaState' for the correct type

ctw_resources.update_doc_reveals(team)
	-- Updates the documentation page for the specified team
	-- Is called automatically on state changes
	-- 'team': 'Team def'


 Inventing API
---------------

ctw_resources.start_inventing(istack, team, pname)
	-- Begins inventing an idea, based on the MetaData in 'istack'
	-- Best called by billboard once the approval letter is posted on it.
	-- 'istack': ItemStack("ctw_resources:approval")
	-- 'team': 'Team def'
	-- Return values:
	--   true: success
	--   false, error_reason: something went wrong
	--     "no_approval_letter" Passed item is not an approval letter
	--     "wrong_team"         Approval letter was issued for another team
	--     "not_approved"       Idea was not approved, letter is faked, or technology is already being invented.

function ctw_resources.get_inventing_progress(team)
	-- Returns the state of all ideas a team is inventing.
	-- Format: Table indexed by 'team_id':
	--   { progress = <in percent>, dp = <dp accumulated so far>, dp_total = <dp total required> }


 References API
----------------

ctw_resources.register_reference(idea_id, itemdef)
	-- Registers a craftitem that opens its assigned idea documentation on punch.
	-- 'itemdef': 'ItemDef' of the item to register
