reseau.throughput = {}

-- Throughput is based on the current *era*
-- Tech developments can increase throughput by some factor though

reseau.throughput.get_wire_throughput = function(wirename)
	-- Wire may belong to a team or belong to no team (e.g. receiver base, which has infinite throughput)
	local nodespec = minetest.registered_nodes[wirename]

	if nodespec.reseau.conductor.infinite_speed then
		return math.huge
	end

	-- This should never fail: All conductors that don't have a team associated to it should be infinite_speed
	assert(nodespec.team_name)
	local multiplier = ctw_technologies.get_team_benefit(teams.get(nodespec.team_name), "cable_throughput_multiplier")
	local technology = reseau.technologies.get_any_node_technology(wirename)
	return reseau.technologies.get_technology_throughput(technology)
end

reseau.throughput.get_experiment_throughput = function()
	-- TODO: tech multipliers
	return reseau.era.get_current().experiment_throughput_limit
end

reseau.throughput.get_receiver_throughput_limit = function()
	-- TODO: tech multipliers
	return reseau.era.get_current().receiver_throughput_limit
end

reseau.throughput.get_router_throughput_limit = function()
	-- TODO: tech multipliers
	return reseau.era.get_current().router_throughput_limit
end
