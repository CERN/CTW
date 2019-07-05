npc.register_npc("steve", {})

npc.register_event("steve", {
	id = "test1",
	dialogue = "$PLAYER, I got something for you! <;:->-]",
	options = {
		{
			text = "get",
			target = function(player, event)
				player:get_inventory():add_item("main", "default:stick")
			end
		}
	}
})

npc.register_event("steve", {
	id = "test2",
	dialogue = "Hello $PLAYER in team $TEAM.",
	options = {
		{ text = "Say HI", target = function() minetest.chat_send_all("NPCI: hi!") end },
		{ text = "GoTo1", target = "test1" },
		{
			text = "teleport",
			target = function(player, event)
				player:set_pos(vector.new(10, 10, 10))
			end
		}
	}
})


npc.register_event("steve", {
		dialogue = "Hello $PLAYER. Good luck on your mission! Move tapes to gain DPs.",
})
