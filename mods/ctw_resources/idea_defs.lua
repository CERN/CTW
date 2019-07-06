-- Craft The Web
-- idea_defs.lua: Definitions of ideas


ctw_resources.register_idea("ascii", {
	name = "ASCII",
	description = "It is necessary to create one unique standard for character encoding that every device complies to.",
	technologies_gained = {
		"ascii",
	},
	technologies_required = {

	},
	references_required = {
		"books:book_blue 3",
		"books:book_red 1",
	},
})

ctw_resources.register_idea("html", {
	name = "Hypertext Markup Language",
	description = "We need a standardized language to express documents with hyperlinks!",
	technologies_gained = {
		"html",
	},
	technologies_required = {
		"ascii",
	},
	references_required = {
		"books:book_green 2",
		"books:book_red 1",
	}
})
ctw_resources.register_idea("ethernet", {
	name = "Ethernet",
	description = "We could send network data over a twisted-pair cable!",
	technologies_gained = {
		"ethernet",
		"lan",
	},
	technologies_required = {

	},
	references_required = {
		"books:book_red 5",
	},
})

ctw_resources.register_idea("www", {
	name = "The World Wide Web",
	description = "With all those technologies gathered, we can finally create the World Wide Web!",
	technologies_gained = {
		"www",
	},
	technologies_required = {
		"html",
		"lan",
	},
	references_required = {
		"books:book_red 1",
	},
})
