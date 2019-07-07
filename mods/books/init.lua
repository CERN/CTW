--[[
	This flag should be set to false if you are building the world that will be preloaded.
	However, in normal play, it should be set to true.
]]--
local enable_bookshelf_randomization = false

local book_types = {
	white = { "", "" },
	red = {
		"Red book",
		"This is a book that is red and contains interesting information"
	},
	green = {
		"Green book",
		"This is a book that is green and contains interesting information"
	},
	blue = {
		"Blue book",
		"This is a book that is blue and contains interesting information"
	},
	yellow = {
		"Yellow book",
		"This is a book that is yellow and contains interesting information"
	},
	orange = {
		"Orange book",
		"This is a book that is orange and contains interesting information"
	},
	purple = {
		"Purple book",
		"This is a book that is purple and contains interesting information"
	},
}

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
	if can_be_taken then
		ctw_resources.register_reference("books:book_" .. key, {
			description = description,
			_ctw_longdesc = d[2],
			inventory_image = "books_book_" .. key .. ".png",
			stack_max = 1,
		})
	end

	minetest.register_node("books:bookshelf_" .. key, {
		tiles = { "books_bookshelf_top.png", "books_bookshelf_bottom.png",
		          "books_bookshelf_side.png", "books_bookshelf_side.png",
		          "books_bookshelf_" .. key .. ".png", "books_bookshelf_" .. key .. ".png" },
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
				minetest.get_node_timer(pos):start(math.random(book_respawn_time_min, book_respawn_time_max))
			end
		end
	})

	if can_be_taken then
		minetest.register_node("books:bookshelf_empty_" .. key, {
			tiles = { "books_bookshelf_top.png", "books_bookshelf_bottom.png",
			          "books_bookshelf_side.png", "books_bookshelf_side.png",
			          "books_bookshelf_empty_" .. key .. ".png", "books_bookshelf_empty_" .. key .. ".png" },
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

local function read_file(filename)
	local file = io.open(filename, "r")
	if file ~= nil then
		local file_content = file:read("*all")
		io.close(file)
		return file_content
	end
	return ""
end

local function write_file(filename, data)
	local file, err = io.open(filename, "w")
	if file then
		file:write(data)
		io.close(file)
	else
		error(err)
	end
end

if enable_bookshelf_randomization then
	local worldpath = minetest.get_worldpath()
	-- See if libraries have been generated during a previous run
	local fixed_libraries = read_file(worldpath .. "/libraries_fixed.json")

	if fixed_libraries == "" then
		-- No libraries generated yet. Try to open the file giving which libraries should go where
		fixed_libraries = {}
		local index = 1
		local data = minetest.parse_json(read_file(worldpath .. "/libraries.json"))
		print(data)
		if data ~= nil then
			for group_type, group_data in pairs(data) do
				-- Shuffle each group
				local area_locations = group_data.libraries
				local area_types = group_data.types
				local n = #area_locations
				assert (n == #area_types)
				for i = n,1,-1 do
					local library = area_locations[i]
					local idx = math.random(1, i)
					local types = area_types[idx]
					area_types[idx] = area_types[i]
					fixed_libraries[index] = { minp = library.minp, maxp = library.maxp, types = types }
					index = index + 1
				end
			end
			-- Save the result for future loads
			write_file(worldpath .. "/libraries_fixed.json", minetest.write_json(fixed_libraries))
		end
	else
		fixed_libraries = minetest.parse_json(fixed_libraries)
	end

	if fixed_libraries ~= nil then
		local area_store = AreaStore()

		for i, library in ipairs(fixed_libraries) do
			area_store:insert_area(library.minp, library.maxp, tostring(i))
		end

		minetest.register_lbm({
			label = "Randomize bookshelves",
			name = "books:randomize",
			nodenames = { "group:bookshelf" },
			action = function(pos, node)
				local areas = area_store:get_areas_for_pos(pos, false, true)
				local nareas = 0
				while areas[nareas] ~= nil do
					nareas = nareas + 1
				end
				assert (nareas <= 1)
				if areas[0] ~= nil then
					local key = random_book_type(fixed_libraries[tonumber(areas[0].data)].types)
					node.name = "books:bookshelf_" .. key
					minetest.swap_node(pos, node)
				end
			end,
		})
	end
else
	minetest.log("error",
		"Bookshelf randomization disabled. Please make sure you are "..
		"pre-building the world and not playing a game.")
end
