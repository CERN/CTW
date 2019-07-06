-- Home Decor API/functions, and common textures and models
-- by VanessaE

local modpath = minetest.get_modpath("homedecor_common")

homedecor = {}
homedecor.modpath = modpath

-- Determine if the item being pointed at is the underside of a node (e.g a ceiling)
function homedecor.find_ceiling(itemstack, placer, pointed_thing)
	-- most of this is copied from the rotate-and-place function in builtin
	local unode = core.get_node_or_nil(pointed_thing.under)
	if not unode then
		return
	end
	local undef = core.registered_nodes[unode.name]
	if undef and undef.on_rightclick then
		undef.on_rightclick(pointed_thing.under, unode, placer,
				itemstack, pointed_thing)
		return
	end

	local above = pointed_thing.above
	local under = pointed_thing.under
	local iswall = (above.y == under.y)
	local isceiling = not iswall and (above.y < under.y)
	local anode = core.get_node_or_nil(above)
	if not anode then
		return
	end
	local pos = pointed_thing.above
	local node = anode

	if undef and undef.buildable_to then
		pos = pointed_thing.under
		node = unode
	end

	if core.is_protected(pos, placer:get_player_name()) then
		core.record_protection_violation(pos,
				placer:get_player_name())
		return
	end

	local ndef = core.registered_nodes[node.name]
	if not ndef or not ndef.buildable_to then
		return
	end
	return isceiling, pos
end

screwdriver = screwdriver or {}

homedecor.plain_wood    = { name = "homedecor_generic_wood_plain.png",  color = 0xffa76820 }
homedecor.mahogany_wood = { name = "homedecor_generic_wood_plain.png",  color = 0xff7d2506 }
homedecor.white_wood    = "homedecor_generic_wood_plain.png"
homedecor.dark_wood     = { name = "homedecor_generic_wood_plain.png",  color = 0xff39240f }
homedecor.lux_wood      = { name = "homedecor_generic_wood_luxury.png", color = 0xff643f23 }

homedecor.color_black     = 0xff303030
homedecor.color_dark_grey = 0xff606060
homedecor.color_med_grey  = 0xffa0a0a0

-- load different handler subsystems
dofile(modpath.."/nodeboxes.lua")
dofile(modpath.."/expansion.lua")
dofile(modpath.."/furnaces.lua")
dofile(modpath.."/inventory.lua")
dofile(modpath.."/registration.lua")
dofile(modpath.."/water_particles.lua")

if minetest.settings:get_bool("log_mod") then
	minetest.log("action", "[HomeDecor API] Loaded!")
end
