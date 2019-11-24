for tname, _ in pairs(teams.get_dict()) do
	minetest.register_node("reseau:receiver_" .. tname, {
		description = tname .. " receiver",
		tiles = {
			"default_gold_block.png",
		},
		groups = { snappy = 3, not_in_creative_inventory = 1, placeholder_receiver=1 },
	})
end

local function set_team(pos, tname)
	local meta = minetest.get_meta(pos)
	meta:set_string("team", tname)
end

minetest.register_lbm({
	label = "Assign teams to receivers",
	name = "reseau:teamise",
	nodenames = { "group:placeholder_receiver" },
	run_at_every_load = true,
	action = function(pos, node)
		local tname = node.name:match("_([a-z]+)$")

		node.name = "reseau:receiverbase"
		minetest.swap_node(pos, node)
		set_team(pos, tname)

		pos.y = pos.y + 1
		node.name = "reseau:receiverscreen"
		minetest.set_node(pos, node)
		set_team(pos, tname)
	end,
})

minetest.register_lbm({
	label = "Assign teams to experiments",
	name = "reseau:teamise2",
	nodenames = { "group:experiment" },
	run_at_every_load = true,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		if meta:contains("formspec") then
			return
		end

		minetest.registered_nodes[node.name].on_construct(pos)
		reseau.try_launch_autotransmitter(pos, node)
	end,
})
