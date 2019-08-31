-- Craft The Web
-- idea_defs.lua: Definitions of ideas

local S = minetest.get_translator("ctw_resources")

-- === DATA FORMATS === --
ctw_resources.register_idea("sgml", {
	name = S("SGML"),
	description = S("Enriched and formatted text that is human- and machine-readable."),
	technologies_gained = {
		"sgml",
	},
	references_required = {
		"books:book_data_formats 2"
	},
})

ctw_resources.register_idea("html", {
	name = S("Hypertext Markup Language"),
	description = S("We need a standardized language to express documents with hyperlinks!"),
	technologies_gained = {
		--"html",
	},
	references_required = {
		"books:book_data_formats 1",
		"books:book_program_c 2",
	}
})


-- === WIRES === --
ctw_resources.register_idea("ethernet", {
	name = S("Ethernet"),
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
	name = S("Apollo/Domain Server Remote Control"),
	description = S("This technology implements remote-controlling servers on the network." ..
		" As a result, servers can be monitored from a single computer."),
	technologies_gained = {
		"tcpip"
	},
	references_required = {
		"books:book_program_objc 1",
	},
})

ctw_resources.register_idea("tcp_ip", {
	name = S("TCP/IP Packet Transport"),
	description = S("Network packets are often lost, corrupted or only partially available." ..
		" How about inventing a protocol which implements those checks?"),
	technologies_gained = {
		"tcpip",
	},
	references_required = {
		"books:book_data_formats 2",
		"books:book_program_c 1",
	},
})

ctw_resources.register_idea("merge_router", {
	name = S("Wire routing"),
	description = S("Some of our cables are only used partially. Please invent something"..
		" so that we can merge and split cables to connect multiple servers."),
	technologies_gained = {
		"merger",
	},
	references_required = {
		"books:book_hf_freq 1",
		"books:book_data_formats 1",
		"books:book_cable_crafting 3",
	},
})

ctw_resources.register_idea("httpd", {
	name = S("First WWW server"),
	description = S("The time has come to write the first server for the world wide web."),
	technologies_gained = {
		"httpd",
	},
	references_required = {
		"books:book_program_c 2",
		"books:book_program_objc 1",
	},
})
