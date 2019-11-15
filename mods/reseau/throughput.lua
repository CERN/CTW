reseau.throughput = {}

-- Wire throughput can depend on: Era, wire technology, tech developments
-- Experiment throughput can depend on: Era, tech developments
-- Receiver throughput can depend on: Era
-- Router throughput can depend on: Era, tech developments

reseau.throughput.get_wire_throughput = function(wirename)
	-- Wire may belong to a team or belong to no team (e.g. receiver base, which has infinite throughput)
	local nodespec = minetest.registered_nodes[wirename]

	if nodespec.reseau.conductor.infinite_speed then
		return math.huge
	end

	-- This should never fail: All conductors that don't have a team associated to it should be infinite_speed
	assert(nodespec.team_name)
	local multiplier = ctw_technologies.get_team_benefit(teams.get(nodespec.team_name), "wire_throughput_multiplier")
	local technology = reseau.technologies.get_any_node_technology(wirename)
	return reseau.technologies.get_technology_throughput(technology) * multiplier
end

reseau.throughput.get_experiment_throughput = function(nodename)
	local nodespec = minetest.registered_nodes[nodename]
	assert(nodespec.team_name)
	local multiplier = ctw_technologies.get_team_benefit(teams.get(nodespec.team_name), "experiment_throughput_multiplier")

	return reseau.era.get_current().experiment_throughput_limit * multiplier
end

reseau.throughput.get_receiver_throughput_limit = function()
	return reseau.era.get_current().receiver_throughput_limit
end

reseau.throughput.get_router_throughput_limit = function(nodename)
	local nodespec = minetest.registered_nodes[nodename]
	assert(nodespec.team_name)
	local multiplier = ctw_technologies.get_team_benefit(teams.get(nodespec.team_name), "router_throughput_multiplier")

	return reseau.era.get_current().router_throughput_limit * multiplier
end
