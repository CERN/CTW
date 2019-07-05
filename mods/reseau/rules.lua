reseau.rules = {}
reseau.rules.default = {
	{x =  0, y =  0, z = -1},
	{x =  1, y =  0, z =  0},
	{x = -1, y =  0, z =  0},
	{x =  0, y =  0, z =  1},
	{x =  1, y =  1, z =  0},
	{x =  1, y = -1, z =  0},
	{x = -1, y =  1, z =  0},
	{x = -1, y = -1, z =  0},
	{x =  0, y =  1, z =  1},
	{x =  0, y = -1, z =  1},
	{x =  0, y =  1, z = -1},
	{x =  0, y = -1, z = -1},
}

reseau.get_any_rules = function(nodename)
	local node = minetest.registered_nodes[nodename]
	local rules = {}

	if node.reseau then
		if node.reseau.conductor then
			rules = reseau.mergetable(rules, node.reseau.conductor.rules)
		elseif node.reseau.transmitter then
			rules = reseau.mergetable(rules, node.reseau.transmitter.rules)
		elseif node.reseau.receiver then
			rules = reseau.mergetable(rules, node.reseau.receiver.rules)
		end
	end

	return rules
end

reseau.rules_link_oneway = function(startpos, startrules, destinationpos)
	for _, rule in ipairs(startrules) do
		if vector.equals(vector.add(startpos, rule), destinationpos) then
			return true
		end
	end

	return false
end

reseau.get_all_links = function(startpos)
	local links = {}

	local startnode = minetest.get_node(startpos)
	local startrules = reseau.get_any_rules(startnode.name)
	for _, rule in ipairs(startrules) do
		local target_pos = vector.add(startpos, rule)
		local target_nodename = minetest.get_node(target_pos).name
		local target_nodespec = minetest.registered_nodes[target_nodename]
		if target_nodespec.reseau and (target_nodespec.reseau.conductor or target_nodespec.reseau.receiver) then
			local target_rules = reseau.get_any_rules(target_nodename)
			if reseau.rules_link_oneway(target_pos, target_rules, startpos) then
				table.insert(links, target_pos)
			end
		end
	end

	return links
end
