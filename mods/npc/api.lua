
-- Dare you accessing this table outside this mod
npc.registered_events = {}
npc.registered_npcs = {}

math.randomseed(os.time())

local function table_index(t, what)
	for k, v in pairs(t) do
		if v == what then
			return k
		end
	end
end

function npc.register_event(npc_name, def)
	assert(npc.registered_events[npc_name], "NPC " ..
			npc_name .. " was yet not registered")
	assert(npc_name)
	assert(def.dialogue)
	def.options = def.options or {}
	table.insert(npc.registered_events[npc_name], def)
end

-- 1) Give idea (state = "undiscovered")
function npc.register_event_idea_discover(npc_name, idea_id, def_e)
	local idea_def = ctw_resources.get_idea(idea_id)
	def_e = def_e or {}
	local def = {}
	def.dialogue = def_e.dialogue or idea_def.description
	def.conditions = {{
		idea = {idea_id, "eq", "undiscovered"},
		dp_min = def_e.dp_min,
		func = function(player)
			local status, message = ctw_resources.give_idea(
				idea_id, player:get_player_name(),
				player:get_inventory(), "main", true)
			if status then
				return #idea_def.references_required + 1
			end
			print("NPC discovery", idea_id, message)
		end
	}}
	def.options = {{
		text = "New discovery",
		target = function(player, event)
			-- Mark as 'discovered'
			ctw_resources.give_idea(idea_id, player:get_player_name(),
				player:get_inventory(), "main")
		end
	}}
	npc.register_event(npc_name, def)
end

-- 2) Approve (needs state = "pubished")
function npc.register_event_idea_approve(npc_name, idea_id, def_e)
	local idea_def = ctw_resources.get_idea(idea_id)
	def_e = def_e or {}
	local def = {}
	def.dialogue = def_e.dialogue or idea_def.description
	def.conditions = {{
		idea = {idea_id, "eq", "published"},
		dp_min = def_e.dp_min,
		item = "ctw_resources:idea_" .. idea_id,
		func = function(player)
			local status, _ = ctw_resources.approve_idea(
					idea_id, player:get_player_name(),
					player:get_inventory(), "main", true)
			if status then -- success
				return #idea_def.references_required + 1
			end
		end
	}}
	def.options = {{
		text = "Approve",
		target = function(player, event)
			-- Mark as 'approved'
			local status, message = ctw_resources.approve_idea(idea_id,
					player:get_player_name(), player:get_inventory(), "main")
			if not status then
				print("NPC: " .. message)
			end
		end
	}}
	npc.register_event(npc_name, def)

	-- Missing items
	def = table.copy(def) -- drop reference
	def.dialogue = table.concat({"I see you'd like to research the following idea:",
		idea_def.description,
		"But you still need a few items. Please collect the required resources."}, "\n")
	def.conditions = {{
		idea = {idea_id, "eq", "published"},
		dp_min = def_e.dp_min and (def_e.dp_min * 0.9),
		item = "ctw_resources:idea_" .. idea_id,
		func = function(player)
			local status, _ = ctw_resources.approve_idea(
					idea_id, player:get_player_name(),
					player:get_inventory(), "main", true)
			if not status then
				return #idea_def.references_required
			end
		end
	}}
	def.options = {{ text = "Okay", target = function() end }}
	npc.register_event(npc_name, def)
end

local function check_lut_comparison(value_1, cmp, value_2, lut)
	if cmp == "eq" then
		return value_1 == value_2
	end
	local index_1 = table_index(lut, value_1)
	local index_2 = table_index(lut, value_2)
	assert(index_1, "Invalid LUT entry 1 '" .. value_1 .. "'")
	assert(index_2, "Invalid LUT entry 2 '" .. value_2 .. "'")
	if cmp == "lt" then
		return index_1 < index_2
	end
	if cmp == "gt" then
		return index_1 > index_2
	end
	error("Invalid comparison: " .. cmp)
end

local function check_condition(player, c)
	local weight = 0
	local teamdef = teams.get_by_player(player)
	if c.dp_min then
		if teams.get_points(teamdef.name) < c.dp_min then
			return
		end
		weight = weight + 1
	end
	if c.idea then
		local current = ctw_resources.get_team_idea_state(c.idea[1], teamdef).state
		if not check_lut_comparison(current, c.idea[2], c.idea[3],
				ctw_resources.idea_states) then
			return
		end
		weight = weight + 1
	end
	if c.tech then
		local current = ctw_technologies.get_team_tech_state(c.tech[1], teamdef).state
		if not check_lut_comparison(current, c.tech[2], c.tech[3],
				{"undiscovered", "gained"}) then
			return
		end
		weight = weight + 1
	end
	if c.func then
		local w = c.func(player)
		if not w then
			return
		end
		weight = weight + w
	end
	if c.item then
		if not player:get_inventory():contains_item("main", c.item) then
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

	local weight_max = -0xFFFF
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

local player_formspecs = {}

function npc.show_dialogue(player, npc_name, def)
	local player_name = player:get_player_name()
	if not def then
		-- Pick something
		def = find_best_matching_event(player, npc_name)
	end
	if not def then
		minetest.chat_send_player(player_name, "Sorry, I don't have any news for you.")
		return
	end

	-- TODO: Translation goes here
	local answer = def.dialogue
	answer = answer:gsub("$PLAYER", player_name)
	local team_def = teams.get_by_player(player_name)
	answer = answer:gsub("$TEAM", team_def and team_def.name or "Singleplayer")

	local fs = {
		"size[10,%f]",
		--"real_coordinates[true]",
		("textarea[0.5,1;9,3;;%s;%s]"):format(
			minetest.formspec_escape(npc.registered_npcs[npc_name].infotext),
			minetest.formspec_escape(answer)
		)
	}

	local button_spacing = 5
	local button_y_pos = 4
	local function add_button(i, option)
		if i % 2 == 0 then
			button_y_pos = button_y_pos + 1 -- + 1.5
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

	obj:set_yaw(math.random() * math.pi * 2)
	obj:set_properties({
		visual_size = { x = def.size, y = def.size },
		textures = def.textures,
		collisionbox = def.collisionbox,
		infotext = def.infotext
	})
	obj:set_armor_groups({immortable=1})

	-- Wiggle animation
	obj:get_luaentity()._npc_name = npc_name
	local model = player_api.registered_models["character.b3d"]
	obj:set_animation(model.animations["stand"], model.animation_speed, 0)
end

function npc.register_npc(npc_name, def)
	def.size = def.size or 1
	def.infotext = def.infotext or ""
	def.nametag = def.nametag or def.infotext
	def.textures = def.textures or { "character.png" }

	if not def.collisionbox then
		def.collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}
		for i, s in ipairs(def.collisionbox) do
			def.collisionbox[i] = s * def.size
		end
	end

	npc.registered_npcs[npc_name] = def
	npc.registered_events[npc_name] = {}
	minetest.register_node("npc:npc_" .. npc_name, {
		description = "NPC node " .. npc_name,
		paramtype = "light",
		drawtype = "airlike",
		inventory_image = "default_stick.png",
		walkable = false,
		pointable = false,
		liquids_pointable = true,
		groups = { npc_spawner = 1 },
		on_construct = function(pos)
			spawn_entity(pos, npc_name)
		end
	})
end

minetest.register_lbm({
	label = "Spawn NPCs",
	name = "npc:spawn_npcs",
	nodenames = {"group:npc_spawner"},
	run_at_every_load = true,
	action = function(pos, node)
		local npc_name = node.name:match("npc:npc_(.*)")
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
