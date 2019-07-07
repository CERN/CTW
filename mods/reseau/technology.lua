reseau.technologies = {}
reseau.technologies.db = {}

reseau.technologies.register = function(name, technology)
	reseau.technologies.db[name] = technology
end

reseau.technologies.get = function(technology)
	return reseau.technologies.db[technology]
end

reseau.technologies.getAll = function(technology)
	return reseau.technologies.db
end

reseau.technologies.all = function()
	local all = {}
	for techname in pairs(reseau.technologies.db) do
		table.insert(all, techname)
	end
	return all
end

-- get a list of all the technologies that a node supports, no matter
-- whether it is conductor / receiver / transmitter
reseau.technologies.get_any_node_technology = function(nodename)
	local nodespec = minetest.registered_nodes[nodename]
	local technology = nil

	if nodespec and nodespec.reseau then
		if nodespec.reseau.conductor then
			technology = nodespec.reseau.conductor.technology
		elseif nodespec.reseau.receiver then
			technology = nodespec.reseau.receiver.technology
		elseif nodespec.reseau.transmitter then
			technology = nodespec.reseau.transmitter.technology
		end
	end

	return technology
end

-- return whether or not the two nodes with node names nodename1 and nodename2
-- have at least one common technology - both nodes may either only support
-- one technology (e.g. both copper wires) or support multiple technologies
-- (e.g. experiments / receivers support all available technologies)
reseau.technologies.node_technologies_compatible = function(nodename1, nodename2)
	local technology1 = reseau.technologies.get_any_node_technology(nodename1)
	local technology2 = reseau.technologies.get_any_node_technology(nodename2)

	if type(technology1) == "string" and type(technology2) == "string" then
		return technology1 == technology2
	elseif type(technology1) == "table" and type(technology2) == "string" then
		return reseau.table_contains(technology1, technology2)
	elseif type(technology1) == "string" and type(technology2) == "table" then
		return reseau.table_contains(technology2, technology1)
	elseif type(technology1) == "table" and type(technology2) == "table" then
		return #reseau.table_intersection(technology1, technology2) > 0
	end
end

-- technology throughput may be static be also depend on year / era / technologies
-- if a node is compatible with multiple technologies, the best throughput is chosen
-- returns throughput in MB/s
reseau.technologies.get_technology_throughput = function(technologies)
	if type(technologies) == "string" then
		technologies = {technologies}
	end

	local best_throughput = 0
	for _, tech in ipairs(technologies) do
		local throughput = reseau.technologies.get(tech).throughput
		if throughput > best_throughput then
			best_throughput = throughput
		end
	end

	return best_throughput
end
