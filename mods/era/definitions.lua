-- ######################
-- # Default (Fallback) #
-- ######################
era.default = {
	name = "default",
	tape_capacity = 99, -- tape capacity in MB
	dp_multiplier = 1, -- discovery points per delivered MB
	experiment_throughput_limit = 9, -- experiment data generation speed in MB/s
	router_throughput_limit = 9, -- router cache in MB/s
	receiver_throughput_limit = 9 -- throughput limit of receiver
}

-- ######################
-- #  Era Definitions   #
-- ######################
era.register(true, 1987, {
	name = "Internet Stone Age",
	tape_capacity = 40,
	dp_multiplier = 2,
	experiment_throughput_limit = 2,
	router_throughput_limit = 20,
	receiver_throughput_limit = 20
})

era.register(1987, 1989, {
	name = "Early Days of Hypertext",
	tape_capacity = 100,
	dp_multiplier = 1,
	experiment_throughput_limit = 4,
	router_throughput_limit = 20,
	receiver_throughput_limit = 50
})

era.register(1989, 1991, {
	name = "HTML and HTTP",
	tape_capacity = 400,
	dp_multiplier = 1,
	experiment_throughput_limit = 10,
	router_throughput_limit = 20,
	receiver_throughput_limit = 100
})

era.register(1991, 1993, {
	name = "Earliest Browsers",
	tape_capacity = 600,
	dp_multiplier = 1,
	experiment_throughput_limit = 40,
	router_throughput_limit = 500,
	receiver_throughput_limit = 1000
})

era.register(1993, true, {
	name = "Standardization and Liberation",
	tape_capacity = 800,
	dp_multiplier = 1,
	experiment_throughput_limit = 80,
	router_throughput_limit = 1000,
	receiver_throughput_limit = 1000
})
