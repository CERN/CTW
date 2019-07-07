
-- === DATA FORMATS === --
ctw_technologies.register_technology("ascii", {
	name = "ASCII",
	description = "There is a standard code for character encoding!",
	year = 1989,
	requires = {
	},
	benefits = {
		{image = "ctw_texture_missing.png", label = "Some benefit"}
	},
})

ctw_technologies.register_technology("html", {
	name = "Hypertext Markup Language",
	description = "There is a standardized language to express documents with hyperlinks!",
	year = 1991,
	requires = {
		"ascii"
	},
	benefits = {
		{image = "ctw_texture_missing.png", label = "Some benefit"},
		{image = "ctw_texture_missing.png", label = "Some other benefit"}
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
		{image = "ctw_texture_missing.png", label = "A cable, yay!"}
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
		cable_throughput_multiplier = {
			image = "ctw_texture_missing.png",
			label = "10x faster cable throughput",
			value = 10
		}
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
		cable_throughput_multiplier = {
			image = "ctw_texture_missing.png",
			label = "5x faster cable throughput",
			value = 5
		}
	},
	tree_line = 2,
})
ctw_technologies.register_technology("ethernet", {
	name = "Ethernet",
	description = "You can send network data over a twisted-pair cable!",
	requires = {
		"twisted-pair"
	},
	benefits = {
		cable_throughput_multiplier = {
			image = "ctw_texture_missing.png",
			label = "10x faster cable throughput",
			value = 10
		}
	},
	tree_line = 2,
})

ctw_technologies.register_technology("www", {
	name = "The World Wide Web",
	description = "With all those technologies gathered, you invented the World Wide Web! Yay!",
	requires = {
		"ethernet",
		"html"
	},
	benefits = {
		{image = "ctw_texture_missing.png", label = "You won!"}
	},
})
