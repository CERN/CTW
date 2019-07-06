-- transmit stuff regularly even if it is in unloaded area
if not reseau.db.autotransmitters then
	reseau.db.autotransmitters = {}
end

reseau.try_launch_autotransmitter = function(pos, node)
	if minetest.registered_nodes[node.name].reseau
	and minetest.registered_nodes[node.name].reseau.transmitter
	and minetest.registered_nodes[node.name].reseau.transmitter.autotransmit then
		print("launch succeeded!")
		reseau.db.autotransmitters[minetest.hash_node_position(pos)] = minetest.registered_nodes[node.name].reseau.transmitter.autotransmit.interval
		reseau.db_commit()
		return true
	end
	return false
end

minetest.register_on_placenode(function(pos, node)
	reseau.try_launch_autotransmitter(pos, node)
end)

minetest.register_globalstep(function(dtime)
	for poshash in pairs(reseau.db.autotransmitters) do
		reseau.db.autotransmitters[poshash] = reseau.db.autotransmitters[poshash] - dtime
		if reseau.db.autotransmitters[poshash] < 0 then
			local pos = minetest.get_position_from_hash(poshash)
			local node = minetest.get_node(pos)

			-- If relaunch succeeds (transmitter is still there), then actually transmit!
			if (reseau.try_launch_autotransmitter(pos, node)) then
				minetest.registered_nodes[node.name].reseau.transmitter.autotransmit.action(pos)
			end
		end
	end
end)
