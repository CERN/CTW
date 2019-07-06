--[[
 API DOCUMENTATION
===================

npc.registered_events[npc_name] = NPC_Event[] (array)

NPC_Event = {
		id = ""/nil,
		-- ^ Unique NPC_Event ID for linking answers
		dialogue = "Hello $PLAYER. Good luck on your mission!",
		-- ^ Text to say
		conditions = {
			{ technology = "blag", item = "", weight = 2/nil },
		}
		-- ^ Per table entry: AND-connected conditions
		-- One condition table has to match entirely to be called
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

npc.register_event_from_idea(npc_name, dialogue, idea_name)
	-- 'dialogue': string/nil: Text to say
	-- 'idea_name': From ctw_techologies (untested)

npc.get_event_by_id(id)
	-- ^ Searchs an unique NPC_Event by ID
]]


-- Dare you accessing this table outside this mod
npc.registered_events = {}
npc.registered_npcs = {}

function npc.register_event(name, def)
	assert(name)
	assert(def.dialogue)
	def.options = def.options or {}
	npc.registered_events[name] = npc.registered_events[name] or {}
	table.insert(npc.registered_events[name], def)
end

function npc.register_event_from_idea(name, dialogue, idea_name)
	local idea_def = ctw_resources.get_idea(idea_name)
	local def = {}
	def.dialogue = dialogue or idea_def.description
	def.conditions = { { idea_id = idea_name } }
	def.options = { { text = "Thank you!" } }
	npc.register_event(name, def)
end

local player_formspecs = {}

local function check_condition(player, c)
	local weight = 0
	if c.dp_min then
		local teamdef = teams.get_by_player(player)
		if teams.get_points(teamdef.name) < c.dp_min then
			return
		end
		weight = weight + 1
	end
	if c.idea_id then
		-- From ctw_resources
		if not ctw_resources.is_idea_approved(c.idea_id,
				{ "tech1", "tech2" }, player:get_inventory(), "main") then
			return
		end
		weight = weight + ctw_resources.get_idea(c.idea_id).technologies_required
	end
	if c.item then
		if not player:get_inventory():contains_item(c.item) then
			return
		end
		weight = weight + 1
	end
	return weight + (c.weight or 0) -- Success
end


-- Check whether any condition of the event matches
-- Parameter 'def': internal event_table entry
-- Returns: weight (0 = no match)
local function check_conditions(player, def)
	if not def.conditions then
		return 0 -- Nothing to do
	end

	local weight_max = 0
	for i, condition in ipairs(def.conditions) do
		local weight = check_condition(player, condition)
		if weight then
			weight_max = math.max(weight_max, weight)
		end
	end

	return weight_max
end

-- Finds the best matching event, weighted by #conditions
-- Takes a random entry from the best matches
-- Returns: NPC_Event/nil
local function find_best_matching_event(player, npc_name)
	local list = npc.registered_events[npc_name]
	local matches = {}
	local weight_max = 0

	for i, event in ipairs(list) do
		local weight = check_conditions(player, event)
		-- Do not add garbage answers (performance)
		if weight >= weight_max then
			table.insert(matches, { weight = weight, def = event })
			weight_max = math.max(weight_max, weight)
		end
	end

	-- Find the most complicated event combination
	table.sort(matches, function(a, b) return a.weight > b.weight end)

	local top_matches = {}
	for i, match in ipairs(matches) do
		if match.weight < weight_max then
			break -- Found the first worse
		end
		-- Insert until the top results are handled
		table.insert(top_matches, match.def)
	end

	return top_matches[math.random(#top_matches)]
end

function npc.get_event_by_id(id)
	for name, list in pairs(npc.registered_events) do
		for i, def in ipairs(list) do
			if def.id == id then
				return def
			end
		end
	end
end

function npc.show_dialogue(player, npc_name, def)
	local player_name = player:get_player_name()
	if not def then
		-- Pick something
		def = find_best_matching_event(player, npc_name)
	end
	assert(def, "Cannot find any matching event")

	-- TODO: Translation goes here
	local answer = def.dialogue
	answer = answer:gsub("$PLAYER", player_name)
	answer = answer:gsub("$TEAM", "TODO")

	local fs = {
		"size[10,%f]",
		"real_coordinates[true]",
		("textarea[0.5,1;9,3;;%s;%s]"):format(
			minetest.formspec_escape(npc.registered_npcs[npc_name].infotext),
			minetest.formspec_escape(answer)
		)
	}

	local button_spacing = 5
	local button_y_pos = 4
	local function add_button(i, option)
		if i % 2 == 0 then
			button_y_pos = button_y_pos + 1.5
		end
		local x = (i % 2) * button_spacing + 0.5

		fs[#fs + 1] = ("button%s[%f,%f;4,1;option_%i;%s]"):format(
			-- Close if it's not going to open another dialogue
			type(option.target) ~= "string" and "_exit" or "",
			-- Show two option per line
			x, button_y_pos,
			i, minetest.formspec_escape(option.text)
		)
	end

	for i, option in ipairs(def.options) do
		add_button(i, option)
	end

	if #def.options == 0 then
		-- Nothing important happened
		add_button(1, { text = "Okay" })
	end

	fs[1] = fs[1]:format(button_y_pos + 1.5)

	player_formspecs[player_name] = { name = npc_name, def = def }
	minetest.show_formspec(player_name, "npc:interaction", table.concat(fs))
end

local function spawn_entity(pos, npc_name)
	local entities = minetest.get_objects_inside_radius(pos, 0.6)
	for i, obj in ipairs(entities) do
		local ent = obj:get_luaentity()
		if ent and ent._npc_name == npc_name then
			return -- Already spawned
		end
	end
	local def = npc.registered_npcs[npc_name]
	pos.y = pos.y - 0.5
	local obj = minetest.add_entity(pos, "npc:npc_generic")

	obj:set_properties({
		visual_size = { x = def.size, y = def.size },
		textures = def.textures,
		collisionbox = def.collisionbox,
		infotext = def.infotext,
	})
	obj:get_luaentity()._npc_name = npc_name
end

function npc.register_npc(npc_name, def)
	def.size = def.size or 1
	def.infotext = def.infotext or ""
	def.textures = def.textures or { "character.png" }

	if not def.collisionbox then
		def.collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}
		for i, s in ipairs(def.collisionbox) do
			def.collisionbox[i] = s * def.size
		end
	end

	npc.registered_npcs[npc_name] = def
	minetest.register_node("npc:npc_" .. npc_name, {
		description = "NPC node",
		tiles = { "default_glass.png" },
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
			},
		},
		groups = { npc_spawner = 1 },
		on_construct = function(pos)
			spawn_entity(pos, npc_name)
		end
	})
end

minetest.register_lbm({
	label = "Spawn NPCs",
	name = "npc:spawn_npcs",
	nodenames = {"groups:npc_spawner"},
	run_at_every_load = true,
	action = function(pos, node)
		local npc_name = node:match("npc:npc_(.*)")
		if not npc_name then
			return
		end
		spawn_entity(pos, npc_name)
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "npc:interaction" then
		return -- Not my beer
	end

	local player_name = player:get_player_name()
	local fs_info = player_formspecs[player_name]
	if not fs_info then
		return -- No open formspecs
	end
	local def = fs_info.def
	local npc_name = fs_info.name

	-- Handle the button presses
	for i, option in ipairs(def.options) do
		if fields["option_" .. i] then
			player_formspecs[player_name] = nil

			if type(option.target) == "string" then
				npc.show_dialogue(player, npc_name, npc.get_event_by_id(option.target))
				return
			end
			option.target(player, def)
			return
		end
	end
end)

-- Clean up garbage
minetest.register_on_leaveplayer(function(player)
	player_formspecs[player:get_player_name()] = nil
end)
