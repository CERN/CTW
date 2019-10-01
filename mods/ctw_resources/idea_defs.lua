-- Craft The Web
-- idea_defs.lua: Definitions of ideas

local S = minetest.get_translator("ctw_resources")

--[[
Ideas ordered by the timeline.
They have prepending comments to indicate what kind of idea it is:
	hardware
	protocol
	service (web)
	software
]]


-- ===========
-- 1980 - 1983
-- ===========

-- software
ctw_resources.register_idea_from_tech("sgml", {
	references_required = {
		"books:book_data_formats 2"
	},
})

-- software
ctw_resources.register_idea_from_tech("enquire", {
	references_required = {
		"books:book_program_c 1",
		"books:book_design 1"
	},
})

-- hardware
ctw_resources.register_idea_from_tech("e10base2", {
	references_required = {
		"books:book_hf_freq 2",
		"books:book_cable_crafting 1",
	},
})

-- protocol
ctw_resources.register_idea_from_tech("tcpip", {
	description = S("Network packets are often lost, corrupted or only partially available." ..
		" How about inventing a protocol which implements those checks?"),
	references_required = {
		"books:book_notebook 3",
		"books:book_data_formats 1"
	},
})

-- hardware
ctw_resources.register_idea_from_tech("ethernet", {
	references_required = {
		"books:book_hf_freq 1",
		"books:book_cable_crafting 2",
		"books:book_hf_freq2 2",
	},
})

-- software
ctw_resources.register_idea_from_tech("gnu", {
	references_required = {
		"books:book_program_c 2",
	},
})

-- ==========
-- -- 1984 --
-- ==========

-- hardware
ctw_resources.register_idea_from_tech("tokenring", {
	references_required = {
		"books:book_cable_crafting 1",
		"books:book_notebook 1",
	},
})

-- service
ctw_resources.register_idea_from_tech("cerndoc", {
	references_required = {
		"books:book_program_c 1",
		"books:book_design 1",
		"books:book_notebook 1",
	},
})

-- service
ctw_resources.register_idea_from_tech("tangle", {
	references_required = {
		"books:book_design 1",
	},
})

-- ==========
-- -- 1985 --
-- ==========

-- hardware
ctw_resources.register_idea_from_tech("fiberproduction", {
	references_required = {
		"books:book_cable_crafting 3",
		"books:book_hf_freq2 1",
	},
})

ctw_resources.register_idea("html", {
	name = S("Hypertext Markup Language"),
	description = S("We need a standardized language to express documents with hyperlinks!"),
	technologies_gained = {
		"html",
	},
	references_required = {
		"books:book_data_formats 1",
		"books:book_program_c 2",
	}
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
