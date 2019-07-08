
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


local worldpath = minetest.get_worldpath()
-- See if libraries have been generated during a previous run
local fixed_libraries = read_file(worldpath .. "/libraries_fixed.json")

if fixed_libraries == "" then
	-- No libraries generated yet. Try to open the file giving which libraries should go where
	fixed_libraries = {}
	local index = 1
	local data = minetest.parse_json(read_file(worldpath .. "/libraries.json"))

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
