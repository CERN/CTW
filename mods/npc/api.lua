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
		-- 'target': an NPC_Event ID or custom 'function(player, npc_name, NPC_Event)'
}

Special 'dialogue' fields:
	$PLAYER = Player name
	$TEAM = Team name


 FUNCTIONS
-----------
npc.register_npc(npc_name, def)
	-- ^ Registers an NPC. 'def' is TODO

npc.register_event(npc_name, NPC_Event)
	-- ^ 'dialogue' must be specified

npc.get_event_by_id(id)
	-- ^ Searchs an unique NPC_Event by ID
]]


-- Dare you accessing this table outside this mod
npc.registered_events = {}

function npc.register_event(name, def)
	assert(name)
	assert(def.dialogue)
	def.options = def.options or {}
	npc.registered_events[name] = npc.registered_events[name] or {}
	table.insert(npc.registered_events[name], def)
end

local player_formspecs = {}

local function check_condition(player, c)
	local weight = 0
	if c.technology then
		if not teams.has_techology(c.technology) then
			return
		end
		weight = weight + 1
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
		"size[7,6]",
		("textarea[0,0;6,3;;NPC says:;%s]"):format(minetest.formspec_escape(answer))
	}

	local button_spacing = 3.5
	local button_y_offset = 4
	local function add_button(i, option)
		fs[#fs + 1] = ("button%s[%f,%f;3,1;option_%i;%s]"):format(
			-- Close if it's not going to open another dialogue
			type(option.target) ~= "string" and "_exit" or "",
			-- Show two option per line
			(i % 2) * button_spacing, math.floor((i - 1) / 2) + button_y_offset,
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

	player_formspecs[player_name] = { name = npc_name, def = def }
	minetest.show_formspec(player_name, "npc:interaction", table.concat(fs))
end

function npc.register_npc(npc_name)
	minetest.register_node("npc:npc_" .. npc_name, {
		description = "NPC node",
		drawtype = "mesh",
		mesh = "character.b3d",
		tiles = { "character.png" },
		visual_scale = 0.1,
		selection_box = {
			type = "fixed",
			fixed = { -0.4, -0.5, -0.4, 0.4, 1.5, 0.4 },
		},
		collision_box = {
			type = "fixed",
			fixed = { -0.4, -0.5, -0.4, 0.4, 1.5, 0.4 },
		},
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			npc.show_dialogue(clicker, npc_name)
		end
	})
end

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
			option.target(player, npc_name, def)
			return
		end
	end
end)

-- Clean up garbage
minetest.register_on_leaveplayer(function(player)
	player_formspecs[player:get_player_name()] = nil
end)
