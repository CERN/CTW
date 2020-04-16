local function file_exists(path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	end

	return false
end


local conf_path = minetest.get_worldpath() .. "/world.conf"
if file_exists(conf_path) then
	world.load_locations(conf_path)
else
	minetest.log("error", "Map configuration for this world not found")
end

local mts_path = minetest.get_worldpath() .. "/world.mts"

local function load_world(load_map_path, load_conf_path, callback)
	assert(load_map_path)
	assert(load_conf_path)
	if not file_exists(load_map_path) then
		return false, "Prebuilt world not found"
	end

	local conf = Settings(load_conf_path)
	local pos1 = minetest.string_to_pos(conf:get("world_1"))
	local pos2 = minetest.string_to_pos(conf:get("world_2"))
	if not pos1 or not pos2 then
		return false, "Unable to read world bounds"
	end

	local area = { from = pos1, to = pos2 }

	world.emerge_with_callbacks(area.from, area.to, function()
		minetest.place_schematic(area.from, load_map_path, "0")
		minetest.after(0.5, function()
			minetest.fix_light(area.from, area.to)

			if callback then
				callback()
			end
		end)
	end)

	return true
end

minetest.register_chatcommand("worldload", {
	func = function(name, param)
		local load_map_path = minetest.get_modpath("world") .. "/schematics/world.mts"
		local load_conf_path = minetest.get_modpath("world") .. "/schematics/world.conf"
		return load_world(load_map_path, load_conf_path)
	end
})

local create_map_path = minetest.get_worldpath() .. "/load_world.mts"
if file_exists(create_map_path) then
	minetest.after(0, function()
		local suc, msg = load_world(create_map_path, conf_path, function()
			os.remove(create_map_path)
		end)
		if not suc then
			error("Error placing map: " .. msg)
		end
	end)
end




minetest.register_on_shutdown(function()
	world.save_locations(conf_path)
end)




local function pos_to_string(pos)
	return ("%d,%d,%d"):format(pos.x, pos.y, pos.z)
end

local HELP = ([[
Click 'set' to set positions to the current position.
Click 'update' to create or update a location with the given location name.
Areas are defined using locations x_1 < x_2, where x is the area name.
Click 'export' to create world.conf and world.mts at world/exports/.
]]):trim()


local function buildLocationList()
	local location_list = {}
	for key, value in pairs(world.get_all_locations()) do
		location_list[#location_list + 1] = { name = key, pos = value }
	end
	table.sort(location_list, function(a, b)
		return a.name < b.name
	end)
	return location_list
end

local function formatList(list)
	for i=1, #list do
		list[i] = minetest.formspec_escape(("%s = %s"):format(list[i].name,  pos_to_string(list[i].pos)))
	end
	return table.concat(list, ",")
end

minetest.register_privilege("builder", {
	give_to_singleplayer = false,
})

sfinv.register_page("world:builder", {
	title = "World Meta",

	is_in_nav = function(self, player, context)
		local privs = minetest.get_player_privs(player:get_player_name())
		return privs.server or privs.builder
	end,

	get = function(self, player, context)
		local area = world.get_area("world") or { from = vector.new(), to = vector.new() }
		context.location_name = context.location_name or "world_1"

		local location_list = buildLocationList()
		local location_selection = ""
		for i=1, #location_list do
			if location_list[i].name == context.location_name then
				location_selection = tostring(i)
				break
			end
		end

		local fs = {
			"real_coordinates[true]",
			"container[0.375,0.375]",
			"field[0,0.3;3.75,0.8;from;From;", pos_to_string(area.from), "]",
			"button[3.75,0.3;1,0.8;set_from;Set]",
			"field[5,0.3;3.75,0.8;to;To;", pos_to_string(area.to), "]",
			"button[8.75,0.3;1,0.8;set_to;Set]",
			"container_end[]",

			"container[0.375,2.225]",
			"box[-0.375,-0.375;10.375,6;#666666cc]",
			"vertlabel[-0.2,1.2;LOCATIONS]",
			"textlist[0,0;9.625,4;locations;", formatList(location_list), ";", location_selection, "]",
			"container[0,4.5]",
			"field[0,0;3.25,0.8;location_name;Name;", context.location_name, "]",
			"field[3.5,0;2.75,0.8;location_pos;Position;", pos_to_string(context.location_pos or vector.new()), "]",
			"button[6.25,0;1,0.8;location_set;Set]",
			"button[7.5,0;2,0.8;location_update;Update]",
			"container_end[]",
			"container_end[]",

			"container[0.375,8.225]",
			"textarea[0,0;9.625,2;;;", minetest.formspec_escape(HELP), "]",
			"container_end[]",

			"button[3.75,9.6;3,0.8;export;Export]",
		}

		return sfinv.make_formspec(player, context,
				table.concat(fs, ""), false)
	end,

	on_player_receive_fields = function(self, player, context, fields)
		if not self:is_in_nav(player, context) then
			return
		end

		if fields.from then
			local pos = minetest.string_to_pos(fields.from)
			world.set_location("world_1", pos)
		end

		if fields.to then
			local pos = minetest.string_to_pos(fields.to)
			world.set_location("world_2", pos)
		end

		if fields.set_from then
			world.set_location("world_1", player:get_pos())
		elseif fields.set_to then
			world.set_location("world_2", player:get_pos())
		end

		context.location_name = fields.location_name or context.location_name

		if fields.location_pos then
			context.location_pos = minetest.string_to_pos(fields.location_pos)
		end

		if fields.locations then
			local evt = minetest.explode_textlist_event(fields.locations)
			if evt.type == "CHG" then
				local list = buildLocationList()
				if evt.index > 0 and evt.index <= #list then
					context.location_name = list[evt.index].name
					context.location_pos = list[evt.index].pos
				end
			end
		elseif fields.location_set then
			context.location_pos = player:get_pos()
		elseif fields.location_update then
			world.set_location(context.location_name, context.location_pos)
		elseif fields.export then
			local area = world.get_area("world")
			if area then
				if file_exists(mts_path) then
					os.remove(mts_path)
				end

				area.from, area.to = vector.sort(area.from, area.to)
				world.set_location("world_1", area.from)
				world.set_location("world_2", area.to)
				world.save_locations(conf_path)

				player:set_inventory_formspec("size[3,2]label[0.1,0.1;Exporting, please wait...]")
				local pname = player:get_player_name()

				world.emerge_with_callbacks(area.from, area.to, function()
					minetest.create_schematic(area.from, area.to, nil, mts_path, nil)
					local player2 = minetest.get_player_by_name(pname)
					if player2 then
						sfinv.set_player_inventory_formspec(player2, context)
					end
					minetest.chat_send_all("Export done!")
				end)
				return
			end
		end

		sfinv.set_player_inventory_formspec(player, context)
		world.save_locations(conf_path)
	end,
})
