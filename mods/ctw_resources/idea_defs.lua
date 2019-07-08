-- Craft The Web
-- idea_defs.lua: Definitions of ideas

local S = minetest.get_translator("ctw_resources")

-- === DATA FORMATS === --
ctw_resources.register_idea("ascii", {
	name = "ASCII",
	description = S("It is necessary to create one unique standard for character encoding that every device complies to."),
	technologies_gained = {
		"ascii",
	},
	references_required = {
		"books:book_data_formats 2"
	},
})

ctw_resources.register_idea("html", {
	name = "Hypertext Markup Language",
	description = S("We need a standardized language to express documents with hyperlinks!"),
	technologies_gained = {
		"html",
	},
	references_required = {
		"books:book_data_formats 1",
		"books:book_program_c 2",
	}
})


-- === WIRES === --
ctw_resources.register_idea("ethernet", {
	name = "Ethernet",
	description = S("We could send network data over a twisted-pair cable!"),
	technologies_gained = {
		"ethernet",
	},
	references_required = {
		"books:book_hf_freq 1",
		"books:book_cable_crafting 2",
		"books:book_hf_freq2 2",
	},
})



-- === NETWORK LOGIC === --

ctw_resources.register_idea("apollo_domain", {
	name = "Apollo/Domain Server Remote Control",
	description = S("This technology implements remote-controlling servers on the network." ..
		" As a result, servers can be monitored from a single computer."),
	technologies_gained = {
		"tcp_ip"
	},
	references_required = {
		"books:book_program_objc 1",
	},
})

ctw_resources.register_idea("tcp_ip", {
	name = "TCP/IP Packet Transport",
	description = S("Network packets are often lost, corrupted or only partially available." ..
		" How about inventing a protocol which implements those checks?"),
	technologies_gained = {
		"tcp_ip",
	},
	references_required = {
		"books:book_data_formats 2",
		"books:book_program_c 1",
	},
})

ctw_resources.register_idea("router", {
	name = "Wire routing",
	description = S("Some of our cables are only used partially. Please invent something"..
		" so that we can merge and split cables to connect multiple servers."),
	technologies_gained = {
		"router",
	},
	references_required = {
		"books:book_hf_freq 1",
		"books:book_data_formats 1",
		"books:book_cable_crafting 3",
	},
})

ctw_resources.register_idea("www", {
	name = "The World Wide Web",
	description = S("With all those technologies gathered, we can finally create the World Wide Web!"),
	technologies_gained = {
		"www",
	},
	references_required = {
		"books:book_program_c 2",
		"books:book_program_objc 1",
	},
})
