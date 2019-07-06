local is_debug = minetest.settings:get_bool("creative_mode")

local handles = {}

local function notify_new_sound(pos)
	local name = minetest.get_node(pos).name
	local def = minetest.registered_items[name]
	if not def then
		return false
	end

	local pos_str = minetest.pos_to_string(pos)
	if handles[pos_str] then
		minetest.sound_stop(handles[pos_str])
	end

	assert(def.emits_sound)
	handles[pos_str] = minetest.sound_play(def.emits_sound, {
		pos = vector.add(pos, def.emits_offset or vector.new()),
		gain = def.emits_gain or 1,
		max_hear_distance = def.emits_distance or 32,
		loop = true,
	})

	if is_debug then
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", dump(def.emits_gain))
	end
end

function world.register_sound(name, spec)
	local def = {
		description = "Sound " .. name,
		drawtype = "airlike",
		groups = { oddly_breakable_by_hand=1, cracky=1, emits_sound=1 },
		after_place_node = notify_new_sound,
		pointable = false,
		diggable = false,
		walkable = false,
		paramtype = "light",
		sunlight_propagates = true,
		on_destruct = function(pos)
			local pos_str = minetest.pos_to_string(pos)
			if handles[pos_str] then
				minetest.sound_stop(handles[pos_str])
			end
		end,
	}

	if is_debug then
		def.drawtype = "torchlike"
		def.tiles = { "sound.png", "sound.png", "sound.png" }
		def.pointable = true
		def.diggable = true
	end

	for key, value in pairs(spec) do
		def["emits_" .. key] = value
	end

	minetest.register_node("sounds:" .. name, def)
end

minetest.register_lbm({
	label = "Detect sound",
	name = "sounds:setup",
	nodenames = { "group:emits_sound" },
	action = notify_new_sound,
	run_at_every_load = true,
})

world.register_sound("datacenter", {
	sound = { name = "datacenter" },
	offset = { x = 0, y = -1, z = 0 },
})
