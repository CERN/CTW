-- Basic setup

local modpath = minetest.get_modpath("npc")
npc = {}

dofile(modpath .. "/api.lua")
dofile(modpath .. "/dialogue_tree.lua")
dofile(modpath .. "/sanity_check.lua")


minetest.register_entity("npc:npc_generic", {
	mesh = "character.b3d",
	visual = "mesh",
	visual_size = {x = 1, y = 1},
	static_save = false,
	physical = true,
	collide_with_objects = true,
	stepheight = 0.6,
	_npc_name = "UNSPECIFIED",
	on_rightclick = function(self, clicker)
		local team = teams.get_by_player(clicker)
		if not team then
			minetest.chat_send_player(clicker:get_player_name(),
					"You seem to have lost your team. Where's it?")
			return
		end
		local dir = vector.subtract(clicker:get_pos(), self.object:get_pos())
		self.object:set_yaw(math.atan2(-dir.x, dir.z))
		minetest.after(1, function()
			npc.show_dialogue(clicker, self._npc_name)
		end)
	end
})
