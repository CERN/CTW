-- This file is a partial copy of functions.lua from minetest_game's beds mod
-- with changes needed for homedecor's beds.

local pi = math.pi
local is_sp = minetest.is_singleplayer()
local enable_respawn = minetest.settings:get_bool("enable_bed_respawn")
if enable_respawn == nil then
	enable_respawn = true
end

-- Helper functions

local function get_look_yaw(pos)
	local n = minetest.get_node(pos)
	local fdir = n.param2 % 4
	if fdir == 0 then
		return pi / 2, fdir
	elseif fdir == 1 then
		return -pi / 2, fdir
	elseif fdir == 3 then
		return pi, fdir
	else
		return 0, fdir
	end
end

local function is_night_skip_enabled()
	local enable_night_skip = minetest.settings:get_bool("enable_bed_night_skip")
	if enable_night_skip == nil then
		enable_night_skip = true
	end
	return enable_night_skip
end

local function check_in_beds(players)
	local in_bed = beds.player
	if not players then
		players = minetest.get_connected_players()
	end

	for n, player in ipairs(players) do
		local name = player:get_player_name()
		if not in_bed[name] then
			return false
		end
	end

	return #players > 0
end

local function get_player_in_bed()
	local player_in_bed = 0
	for k,v in pairs(beds.player) do
		player_in_bed = player_in_bed + 1
	end
	return player_in_bed
end

local function lay_down(player, pos, bed_pos, state, skip)
	local name = player:get_player_name()
	local hud_flags = player:hud_get_flags()

	if not player or not name then
		return
	end

	-- stand up
	if state ~= nil and not state then
		local p = beds.pos[name] or nil
		if beds.player[name] ~= nil then
			beds.player[name] = nil
		end
		-- skip here to prevent sending player specific changes (used for leaving players)
		if skip then
			return
		end
		if p then
			player:setpos(p)
		end

		-- physics, eye_offset, etc
		player:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
		player:set_look_horizontal(math.random(1, 180) / 100)
		default.player_attached[name] = false
		player:set_physics_override(1, 1, 1)
		hud_flags.wielditem = true
		default.player_set_animation(player, "stand" , 30)

	-- lay down
	else
		beds.player[name] = 1
		beds.pos[name] = pos
		-- physics, eye_offset, etc
		player:set_eye_offset({x = 0, y = -13, z = 0}, {x = 0, y = 0, z = 0})
		local yaw, fdir = get_look_yaw(bed_pos)
		player:set_look_horizontal(yaw)
		local offsets = {
			[0] = {0.5,     0},
			[1] = {-0.5,    0},
			[2] = {0,    -0.5},
			[3] = {0,     0.5}
		}
		local p = {x = bed_pos.x + offsets[fdir][1], y = bed_pos.y, z = bed_pos.z + offsets[fdir][2]}
		player:set_physics_override(0, 0, 0)
		player:setpos(p)
		default.player_attached[name] = true
		hud_flags.wielditem = false
		default.player_set_animation(player, "lay" , 0)
	end

	player:hud_set_flags(hud_flags)
end

local function update_formspecs(finished)
	local ges = #minetest.get_connected_players()
	local player_in_bed = get_player_in_bed()
	local form_n
	local is_majority = (ges / 2) < player_in_bed

	if finished then
		form_n = beds.formspec .. "label[2.7,11; Good morning.]"
	else
		form_n = beds.formspec .. "label[2.2,11;" .. tostring(player_in_bed) ..
			" of " .. tostring(ges) .. " players are in bed]"
		if is_majority and is_night_skip_enabled() then
			form_n = form_n .. "button_exit[2,8;4,0.75;force;Force night skip]"
		end
	end

	for name,_ in pairs(beds.player) do
		minetest.show_formspec(name, "beds_form", form_n)
	end
end


-- Public functions

function homedecor.beds_on_rightclick(pos, node, player)
	local name = player:get_player_name()
	local ppos = player:getpos()
	local tod = minetest.get_timeofday()

	if tod > 0.2 and tod < 0.805 then
		if beds.player[name] then
			lay_down(player, nil, nil, false)
		end
		minetest.chat_send_player(name, "You can only sleep at night.")
		return
	end

	-- move to bed
	if not beds.player[name] then
		lay_down(player, ppos, pos)
		beds.set_spawns() -- save respawn positions when entering bed
	else
		lay_down(player, nil, nil, false)
	end

	if not is_sp then
		update_formspecs(false)
	end

	-- skip the night and let all players stand up
	if check_in_beds() then
		minetest.after(2, function()
			if not is_sp then
				update_formspecs(is_night_skip_enabled())
			end
			if is_night_skip_enabled() then
				beds.skip_night()
				beds.kick_players()
			end
		end)
	end
end
