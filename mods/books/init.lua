--[[
	This flag should be set to false if you are building the world that will be preloaded.
	However, in normal play, it should be set to true.
]]--
local enable_bookshelf_randomization = true

if enable_bookshelf_randomization then
	dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/mapgen.lua")
else
	minetest.log("error",
		"Bookshelf randomization disabled. Please make sure you are "..
		"pre-building the world and not playing a game.")
	return
end


local book_types = {
	white = { "", "" },
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
	-- add whatever you want here. colors are key-hash-based
}

if true then -- TODO DEBUG
	minetest.register_on_joinplayer(function(p)
		local inv = p:get_inventory()
		inv:set_list("main", {})
		for key, d in pairs(book_types) do
			inv:add_item("main", "books:bookshelf_" .. key)
		end
	end)
end

local function string_to_color(str)
	local color = 0
	for i = 1, #str do
		local c = str:sub(i, i):byte()
		color = color + c * 2^(i - 1)
	end
	local B = color % 0x10
	local G = math.floor((color % 0x100 ) / 0x10)
	local R = math.floor((color % 0x1000) / 0x100)
	if R + G + B > 24 then
		R = 15 - R
		G = 15 - G
		B = 15 - B
	end
	return string.format("#%X%X%X", R, G, B)
end

local book_respawn_time_min = 10
local book_respawn_time_max = 20

local function random_book_type(probabilities)
	-- Return a random type of book, given the probabilities for each kind.
	-- The probabilities should sum to 1.
	local r = math.random()
	local cur = 0
	local lastkey = nil
	for key, prob in pairs(probabilities) do
		cur = cur + prob
		if r <= cur then
			return key
		end
		lastkey = key
	end
	-- Should not happen, but make sure we handle this case anyway
	minetest.log("warning", "random_book_type could not find a book type!")
	if lastkey ~= nil then
		return lastkey
	end
	error("random_book_type got an empty probability table")
end

for key, d in pairs(book_types) do
	local description = d[1]
	local can_be_taken = description ~= ""
	local color = string_to_color(key)
	if can_be_taken then
		local overlay_book = "books_book_mask.png^[multiply:" .. color
		ctw_resources.register_reference("books:book_" .. key, {
			description = description,
			_ctw_longdesc = d[2],
			inventory_image = "books_book.png^(" .. overlay_book .. ")",
			stack_max = 1,
		})
	end

	local r = math.random(6) -- according to count of "books_bookshelf_*.png"
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
			if puncher ~= nil and can_be_taken then
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
		end
	})

	if can_be_taken then
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
end
