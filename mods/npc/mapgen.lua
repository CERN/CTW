minetest.register_lbm({
	label = "Spawn NPCs",
	name = "npc:spawner",
	nodenames = { "group:npc_spawner" },
	run_at_every_load = true,
	action = function(pos, node)
		local def = minetest.registered_nodes[node.name]
		assert(def)

		def.on_construct(pos)
	end,
})
