--[[
	This flag should be set to false if you are building the world that will be preloaded.
	However, in normal play, it should be set to true.
]]--
local enable_bookshelf_randomization = false
local debug = false

if enable_bookshelf_randomization then
	dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/mapgen.lua")
else
	minetest.log("error",
		"Bookshelf randomization disabled. Please make sure you are "..
		"pre-building the world and not playing a game.")
end


local book_types = {
	-- white: Normal filled bookshelf
	data_formats = {
		"Theory of Data Encoding",
		"Various theoretical examples and ideas regarding byte order"
	},
	hf_freq = {
		"High Frequency Physics",
		"Physics get a bit weird with high frequencies. This is how it works"
	},
	hf_freq2 = {
		"HF Physics Part 2",
		"An advanced scientific report about electorn physics at high frequencies."
	},
	program_objc = {
		"Objective-C How To Program",
		"Programming explained easily. There's how you write Objctive-C programs."
	},
	program_c = {
		"Program in C - The Handbook",
		"Small and compact C programming handbook. Develop applications with this book."
	},
	cable_crafting = {
		"The Art Of Crafting",
		"Metal processing and compact wire designs are part of this book."
	},
	-- add whatever you want here. colors are key-hash-based
}

if debug then
	minetest.register_on_joinplayer(function(p)
		local inv = p:get_inventory()
		inv:set_list("main", {})
		for key, d in pairs(book_types) do
			inv:add_item("main", "books:bookshelf_" .. key)
		end
	end)
end

local function string_to_color(str)
	local color = minetest.sha1(str, true)
	local R = color:byte( 1) % 0x10
	local G = color:byte(10) % 0x10
	local B = color:byte(20) % 0x10
	if R + G + B > 24 then
		R = 15 - R
		G = 15 - G
		B = 15 - B
	end
	return string.format("#%X%X%X", R, G, B)
end

local book_respawn_time_min = 10
local book_respawn_time_max = 20

for key, d in pairs(book_types) do
	local description = d[1]
	local color = string_to_color(key)

	-- Register craftitem and documentation entry
	local overlay_book = "books_book_mask.png^[multiply:" .. color
	ctw_resources.register_reference("books:book_" .. key, {
		description = description,
		_ctw_longdesc = d[2],
		inventory_image = "books_book.png^(" .. overlay_book .. ")",
		stack_max = 1,
	})

	local r = math.random(6) -- according to count of "books_bookshelf_*.png"

	-- Add full bookshelf
	local overlay_full = "books_bookshelf_" .. r .. ".png^[multiply:" .. color
	minetest.register_node("books:bookshelf_" .. key, {
		tiles = {
			"books_bookshelf_side.png", -- top
			"books_bookshelf_side.png", -- bottom
			"books_bookshelf_side.png",
			"books_bookshelf_side.png",
			"books_bookshelf.png^(" .. overlay_full .. ")", -- front
			"books_bookshelf.png^(" .. overlay_full .. ")" -- back
		},
		paramtype2 = "facedir",
		groups = { bookshelf = 1 },
		on_punch = function(pos, node, puncher, pointed_thing)
			if not puncher then
				return
			end
			local inv = puncher:get_inventory()
			if not inv:room_for_item("main", "books:book_" .. key) then
				minetest.chat_send_player(puncher:get_player_name(),
					"Your inventory is full already!")
				return
			end
			inv:add_item("main", "books:book_" .. key)
			node.name = "books:bookshelf_empty_" .. key
			minetest.swap_node(pos, node)
			minetest.get_node_timer(pos):start(
				math.random(book_respawn_time_min, book_respawn_time_max))
		end
	})

	-- Add empty bookshelf
	local overlay_empty = "books_bookshelf_" .. r .. ".png^[multiply:#523f23"
	minetest.register_node("books:bookshelf_empty_" .. key, {
		tiles = {
			"books_bookshelf_side.png", -- top
			"books_bookshelf_side.png", -- bottom
			"books_bookshelf_side.png",
			"books_bookshelf_side.png",
			"books_bookshelf.png^(" .. overlay_empty .. ")",
			"books_bookshelf.png^(" .. overlay_empty .. ")" },
		paramtype2 = "facedir",
		groups = { bookshelf = 1 },
		on_timer = function(pos, elapsed)
			local node = minetest.get_node(pos)
			node.name = "books:bookshelf_" .. key
			minetest.swap_node(pos, node)
		end,
	})
end

minetest.register_node("books:bookshelf_white", {
	tiles = {
		"books_bookshelf_side.png", -- top
		"books_bookshelf_side.png", -- bottom
		"books_bookshelf_side.png",
		"books_bookshelf_side.png",
		"books_bookshelf.png", -- front
		"books_bookshelf.png" -- back
	},
	paramtype2 = "facedir",
	groups = { bookshelf = 1 }
})
