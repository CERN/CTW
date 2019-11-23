local names = {}
for tname, _ in pairs(teams.get_dict()) do	
	names[#names + 1] = "reseau:receiver_" .. tname
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
	label = "Assign teams to things",
	name = "reseau:teamise",
	-- nodenames = { "group:placeholder_receiver" },
	nodenames = names,
	run_at_every_load = true,
	action = function(pos, node)	
		minetest.log("error", ("Found receiver at %s with name %s"):format(minetest.pos_to_string(pos), node.name))

		local tname = node.name:match("_([a-z]+)$")

		node.name = "reseau:receiverbase"
		minetest.swap_node(pos, node)
		set_team(pos, tname)

		pos.y = pos.y + 1
		node.name = "reseau:receiverscreen"
		minetest.swap_node(pos, node)
		set_team(pos, tname)
	
	end,
})
