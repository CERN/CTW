-- Basic setup

local modpath = minetest.get_modpath("npc")
npc = {}

dofile(modpath .. "/api.lua")
dofile(modpath .. "/sanity_check.lua")
dofile(modpath .. "/dialogue_tree.lua")


minetest.register_entity("npc:npc_generic", {
	mesh = "character.b3d",
	visual = "mesh",
	visual_size = {x = 1, y = 1},
	static_save = false,
	stepheight = 0.6,
	_npc_name = "UNSPECIFIED",
	on_rightclick = function(self, clicker)
		local dir = vector.subtract(clicker:get_pos(), self.object:get_pos())
		self.object:set_yaw(math.atan2(-dir.x, dir.z))
		minetest.after(1, function()
			npc.show_dialogue(clicker, self._npc_name)
		end)
	end
})

npc.register_npc("steve", {
	infotext = "Tutor",
	textures = { "npc_skin_lovehart.png" }
})