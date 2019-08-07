local S = minetest.get_translator("ctw_technologies")

--[[
The technologies are ordered by the timeline.
They have prepending comments to indicate what kind of technology it is:
	cable
	protocol
	service (web)
	software
]]

-- cable
ctw_technologies.register_technology("fiber", {
	name = S("Optical Fiber"),
	description = S("Data transfer over light. Fast but experimental and expensive."),
	year = 1960,
})

-- protocol
ctw_technologies.register_technology("ascii", {
	name = S("ASCII"),
	description = S("Standard for character encoding"),
	year = 1966,
})

-- software
ctw_technologies.register_technology("unix", {
	name = S("UNIX v4"),
	description = S("An OS to work fast and efficiently."),
	year = 1973,
})

-- protocol
ctw_technologies.register_technology("crc", {
	name = S("Cyclic Redundancy Check"),
	description = S("Automatic error correction to get valid data."),
	year = 1975,
})

-- ??
ctw_technologies.register_technology("report", {
	name = S("??"),
	description = S("??"),
	year = 1977,
})

-- protocol
ctw_technologies.register_technology("ipnet", {
	name = S("IP Networking"),
	description = S("Addresses for your network computers"),
	year = 1978,
})

-- ===========
-- 1980 - 1983
-- ===========

-- software
ctw_technologies.register_technology("sgml", {
	name = S("SGML"),
	description = S("Enriched and formatted text that is human- and machine-readable."),
	year = 1980,
	requires = {
		"ascii"
	},
	tree_line = 2,
})

-- software
ctw_technologies.register_technology("enquire", {
	name = S("ENQUIRE"),
	description = S("Easy linkable documentation pages."),
	year = 1980,
	requires = {
		"ascii"
	},
	tree_line = 2,
})

-- cable
ctw_technologies.register_technology("e10base2", {
	name = S("E10BASE2 / thin Ethernet"),
	description = S("Coaxial ethernet cables to build up a network."),
	year = 1980,
	requires = {
		"crc"
	},
	benefits = {
		{ type = "supply",  item="reseau:copper_%t_00000000 99", time_min=60, time_max=120 },
	},
	tree_line = 2,
})

-- protocol
ctw_technologies.register_technology("tcpip", {
	name = S("TCP/IP v4"),
	description = S("A reliable protocol to transmit data over a computer network."),
	year = 1981,
	requires = {
		"ipnet"
	},
	benefits = {
		{ type = "wire_throughput_multiplier", value = 2 },
	},
	tree_line = 2,
})

-- cable
ctw_technologies.register_technology("ethernet", {
	name = S("Ethernet Standard"),
	description = S("Standardized cables and data transfer"),
	year = 1983,
	requires = {
		"crc"
	},
	benefits = {
		{ type = "supply", item="reseau:copper_cable" }
	},
	tree_line = 2,
})

-- software
ctw_technologies.register_technology("gnu", {
	name = S("GNU"),
	description = S("The first steps towards a free Operating System."),
	year = 1983,
	requires = {
		"unix"
	},
	tree_line = 2,
})

-- ==========
-- -- 1984 --
-- ==========

-- cable
ctw_technologies.register_technology("tokenring", {
	name = S("4Mbps Token Ring"),
	description = S("An IBM standard to connect computers."),
	year = 1984,
	requires = {
		"ipnet"
	},
	benefits = {
		{ type = "wire_throughput_multiplier", value = 2 }
	},
	tree_line = 2,
})

-- service
ctw_technologies.register_technology("cerndoc", {
	name = S("CERNDOC"),
	description = S("An interactive manuals database by CERN."),
	year = 1984,
	requires = {
		"report"
	},
})

-- service
ctw_technologies.register_technology("tangle", {
	name = S("Tangle"),
	description = S("?? ENQUIRE follow-up"),
	year = 1984,
	requires = {
		"enquire"
	},
})

-- ==========
-- -- 1985 --
-- ==========

-- cable
ctw_technologies.register_technology("fiberproduction", {
	name = S("Fast Optical Fiber Production"),
	description = S("The commercial fiber industry is slowly getting started."),
	year = 1985,
	requires = {
		"fiber"
	},
})

-- service
ctw_technologies.register_technology("dns", {
	name = S("Domain Name Server"),
	description = S("This service translates computer addresses into friendly names."),
	year = 1985,
	requires = {
		"tcpip"
	},
	benefits = { -- more people use it now:
		{ type = "experiment_throughput_multiplier", value = 2 }
	},
})

-- software
ctw_technologies.register_technology("grif", {
	name = S("GrIF SGML editor"),
	description = S("Tech savy people will love to create and edit SGML documents so easily."),
	year = 1985,
	requires = {
		"cerndoc",
		"sgml"
	},
})

-- software
ctw_technologies.register_technology("enquire2", {
	name = S("ENQUIRE v2"),
	description = S("?? what's changed?"),
	year = 1985,
	requires = {
		"cerndoc",
		"sgml"
	},
})

-- ==========
-- -- 1986 --
-- ==========

-- kept for completeness


-- ==========
-- -- 1987 --
-- ==========

-- cable
ctw_technologies.register_technology("twistethernet", {
	name = S("Twisted Pair Ethernet"),
	description = S("Trash your coaxial cables and prepare for reliable high-frequency cables."),
	year = 1987,
	requires = {
		"ethernet",
		"e10base2"
	},
	benefits = {
		{ type = "wire_throughput_multiplier", value = 5 },
		{ type = "receiver_throughput_multiplier", value = 3 },
	},
})

-- service
ctw_technologies.register_technology("gif", {
	name = S("GIF"),
	description = S("Lossless static or animated images. A great end-user experience."),
	year = 1987,
	requires = {
		"grif"
	},
	benefits = {
		{ type = "experiment_throughput_multiplier", value = 2 }
	},
})

-- software
ctw_technologies.register_technology("hypertext", {
	name = S("Hypertext"),
	description = S("Easy linkable content between different network computers."),
	year = 1987,
	requires = {
		"grif",
		"enquire2"
	},
	benefits = {
		{ type = "experiment_throughput_multiplier", value = 2 }
	},
})


-- TODO


ctw_technologies.register_technology("router", {
	name = S("Routers (split, merge)"),
	description = S("Split and merge various kinds of cables to improve the wire usage."),
	year = 1990, -- somewhen after 1989
	requires = {
		--"tcp_ip" -- or better
	},
	benefits = {
		{ type = "supply", item="reseau:splitter_%t", time_min=80, time_max=180 },
		{ type = "supply", item="reseau:merger_%t", time_min=80, time_max=180 },
	},
})


ctw_technologies.register_technology("www", {
	name = S("The World Wide Web"),
	description = S("With all those technologies gathered, you invented the World Wide Web! Yay!"),
	year = 1991,
	requires = {
		--"ethernet",
		--"html"
	},
	benefits = {
		{type="victory"}
	},
})
