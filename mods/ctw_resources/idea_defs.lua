-- Craft The Web
-- idea_defs.lua: Definitions of ideas


ctw_resources.register_idea("ascii", {
	name = "ASCII",
	description = "It is necessary to create one unique standard for character encoding that every device complies to.",
	technologies_gained = {
		"ascii",
	},
	references_required = {
		"books:data_formats 2"
	},
})

ctw_resources.register_idea("html", {
	name = "Hypertext Markup Language",
	description = "We need a standardized language to express documents with hyperlinks!",
	technologies_gained = {
		"html",
	},
	references_required = {
		"books:data_formats 1",
		"books:program_c 2",
	}
})
ctw_resources.register_idea("ethernet", {
	name = "Ethernet",
	description = "We could send network data over a twisted-pair cable!",
	technologies_gained = {
		"ethernet",
	},
	references_required = {
		"books:hf_freq 1",
		"books:cable_crafting 2",
		"books:hf_freq2 2",
	},
})

ctw_resources.register_idea("www", {
	name = "The World Wide Web",
	description = "With all those technologies gathered, we can finally create the World Wide Web!",
	technologies_gained = {
		"www",
	},
	references_required = {
		"books:program_c 2",
		"books:program_objc 1",
	},
})
