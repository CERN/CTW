reseau.get_any_technology = function(nodename)
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

reseau.technologies_compatible = function(nodename1, nodename2)
	local technology1 = reseau.get_any_technology(nodename1)
	local technology2 = reseau.get_any_technology(nodename2)

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
-- TODO: implement smart throughput calculation
reseau.technologies_get_throughput = function(technologies)
	if type(technologies) == "string" then
		technologies = {technologies}
	end

	local best_throughput = 0
	local inc_throughput = function(throughput)
		if best_throughput < throughput then
			best_throughput = throughput
		end 
	end

	for _, tech in ipairs(technologies) do
		if tech == "copper" then
			inc_throughput(20)
		elseif tech == "fiber" then
			inc_throughput(1000)
		end
	end

	return best_throughput
end
