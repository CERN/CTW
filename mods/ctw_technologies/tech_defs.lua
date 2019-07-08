
-- === DATA FORMATS === --
ctw_technologies.register_technology("ascii", {
	name = "ASCII",
	description = "There is a standard code for character encoding!",
	year = 1989,
	requires = {
	},
	benefits = {
	}
})

ctw_technologies.register_technology("html", {
	name = "Hypertext Markup Language",
	description = "There is a standardized language to express documents with hyperlinks!",
	year = 1991,
	requires = {
		"ascii"
	},
	benefits = {
	},
})



-- === WIRES === --
ctw_technologies.register_technology("phonecable", {
	name = "Phone Cable",
	description = "The most basic type of signal cable",
	year = 1984,
	requires = {
	},
	benefits = {
		{ type = "supply", item="reseau:copper_cable" }
	},
	tree_line = 2,
})

ctw_technologies.register_technology("coaxial", {
	name = "Coaxial Cable",
	description = "A cable with one conductor and a shield!",
	requires = {
		"phonecable"
	},
	benefits = {
		{ type = "cable_throughput_multiplier", value = 10 },
		{ type = "supply",  item="reseau:copper_%t_00000000 99", time_min=60, time_max=120 },
	},
	tree_line = 2,
})

ctw_technologies.register_technology("twisted-pair", {
	name = "Twisted-Pair Cable",
	description = "A cable with twisted pairs!",
	requires = {
		"coaxial"
	},
	benefits = {
		{ type = "cable_throughput_multiplier", value = 5 }
	},
	tree_line = 2,
})
ctw_technologies.register_technology("ethernet", {
	name = "Ethernet",
	description = "You can send network data over a twisted-pair cable!",
	year = 1985, -- shielded twisted pair
	requires = {
		"twisted-pair"
	},
	benefits = {
		{ type = "cable_throughput_multiplier", value = 10 }
	},
	tree_line = 2,
})


-- === NETWORK LOGIC === --

ctw_technologies.register_technology("tcp_ip", {
	name = "TCP/IP Packet Transport",
	description = "TCP/IP is a reliable protocol to transmit data over a computer network.",
	year = 1981, -- v4
	--year = 1992, -- timestamps added
	requires = {
		"coaxial" -- or better
	},
	benefits = {
		{ type = "cable_throughput_multiplier", value = 2 },
	},
})

ctw_technologies.register_technology("router", {
	name = "Routers (split, merge)",
	description = "Split and merge various kinds of cables to improve the wire usage.",
	year = 1990, -- somewhen after 1989
	requires = {
		"tcp_ip" -- or better
	},
	benefits = {
		{ type = "supply", item="reseau:splitter_%t", time_min=80, time_max=180 },
		{ type = "supply", item="reseau:merger_%t", time_min=80, time_max=180 },
	},
})


ctw_technologies.register_technology("www", {
	name = "The World Wide Web",
	description = "With all those technologies gathered, you invented the World Wide Web! Yay!",
	year = 1991,
	requires = {
		"ethernet",
		"html"
	},
	benefits = {
		{type="victory"}
	},
})
