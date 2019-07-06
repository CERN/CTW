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

reseau.extract_rules = function(rulesspec, node)
	if type(rulesspec) == "table" then
		return rulesspec
	elseif type(rulesspec) == "function" then
		return rulesspec(node)
	end
end

reseau.get_any_rules = function(pos)
	local node = minetest.get_node(pos)
	local nodespec = minetest.registered_nodes[node.name]
	local rules = {}

	if nodespec.reseau then
		if nodespec.reseau.conductor then
			rules = reseau.mergetable(rules, reseau.extract_rules(nodespec.reseau.conductor.rules, node))
		else
			if nodespec.reseau.transmitter then
				rules = reseau.mergetable(rules, reseau.extract_rules(nodespec.reseau.transmitter.rules, node))
			end
			if nodespec.reseau.receiver then
				rules = reseau.mergetable(rules, reseau.extract_rules(nodespec.reseau.receiver.rules, node))
			end
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

	local startrules = reseau.get_any_rules(startpos)
	for _, rule in ipairs(startrules) do
		local target_pos = vector.add(startpos, rule)
		local target_nodename = minetest.get_node(target_pos).name
		local target_nodespec = minetest.registered_nodes[target_nodename]
		if target_nodespec.reseau and (target_nodespec.reseau.conductor or target_nodespec.reseau.receiver) then
			local target_rules = reseau.get_any_rules(target_pos)
			if reseau.rules_link_oneway(target_pos, target_rules, startpos) then
				table.insert(links, target_pos)
			end
		end
	end

	return links
end

reseau.rotate_rules_right = function(rules)
	local nr = {}
	for i, rule in ipairs(rules) do
		table.insert(nr, {
			x = -rule.z,
			y =  rule.y,
			z =  rule.x,
			name = rule.name})
	end
	return nr
end

reseau.rotate_rules_left = function(rules)
	local nr = {}
	for i, rule in ipairs(rules) do
		table.insert(nr, {
			x =  rule.z,
			y =  rule.y,
			z = -rule.x,
			name = rule.name})
	end
	return nr
end
