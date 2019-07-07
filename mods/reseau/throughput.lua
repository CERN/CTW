reseau.throughput = {}

-- Throughput is based on the current *era*
-- Tech developments can increase throughput by some factor though

reseau.throughput.get_wire_throughput = function(technology)
	-- TODO: tech multipliers
	return reseau.technologies.get_technology_throughput(technology)
end

reseau.throughput.get_experiment_throughput = function()
	-- TODO: tech multipliers
	return reseau.era.get_current().genspeed
end

reseau.throughput.get_receiver_throughput_limit = function()
	-- TODO: tech multipliers
	return reseau.era.get_current().receiver_throughput
end

reseau.throughput.get_router_cache_limit = function()
	-- TODO: tech multipliers
	return reseau.era.get_current().router_max_cache
end
