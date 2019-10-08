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

ctw_resources.register_idea_from_tech("dns", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("grif", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("enquire2", {
	references_required = {},
})


-- ==========
-- -- 1986 --
-- ==========

-- gap


-- ==========
-- -- 1987 --
-- ==========

ctw_resources.register_idea_from_tech("twistethernet", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("gif", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("hypertext", {
	references_required = {},
})


-- ==========
-- -- 1988 --
-- ==========

ctw_resources.register_idea_from_tech("dynroutingrip", {
	references_required = {},
})


-- ==========
-- -- 1989 --
-- ==========

ctw_resources.register_idea_from_tech("dynroutingbgp", {
	references_required = {},
})

ctw_resources.register_idea("merger", {
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

ctw_resources.register_idea_from_tech("gpl", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("hypertextproposal", {
	references_required = {},
})


-- ==========
-- -- 1990 -- v1 + v2
-- ==========

ctw_resources.register_idea_from_tech("fibercommunications", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("http", {
	references_required = {},
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

ctw_resources.register_idea_from_tech("wwwbrowser", {
	references_required = {},
})


-- ==========
-- -- 1991 --
-- ==========

ctw_resources.register_idea_from_tech("cat5", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("linux", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("cernbook", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("cernpage", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("violawww", {
	references_required = {},
})

-- ==========
-- -- 1992 --
-- ==========

ctw_resources.register_idea_from_tech("splitter", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("lynx", {
	references_required = {},
})


-- ==========
-- -- 1993 --
-- ==========

ctw_resources.register_idea_from_tech("cidrrouting", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("gnn", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("wwwpublic", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("mosaic", {
	references_required = {},
})


-- ==========
-- -- 1994 --
-- ==========

ctw_resources.register_idea_from_tech("url", {
	references_required = {},
})

ctw_resources.register_idea_from_tech("netscape", {
	references_required = {},
})


-- ==========
-- -- 1995 --
-- ==========

ctw_resources.register_idea_from_tech("fastethernet", {
	references_required = {},
})
ctw_resources.register_idea_from_tech("iexplore", {
	references_required = {},
})
ctw_resources.register_idea_from_tech("png", {
	references_required = {},
})
ctw_resources.register_idea_from_tech("w3c", {
	references_required = {},
})
