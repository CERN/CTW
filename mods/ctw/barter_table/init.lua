barter_table = {}
barter_table.positions = {}
dofile(minetest.get_modpath("barter_table") .. "/formspec_actions.lua")

function barter_table.meta_reset(meta, k)
	meta:set_string("player_" .. k, nil)
	meta:set_string("tech_" .. k, nil)
	meta:set_string("accept_" .. k, nil)
end

function barter_table.get_parties(pos, meta)
	meta = meta or minetest.get_meta(pos)

	-- Unrolling possible. Using loop for typo-prevention
	local parties = { a = {}, b = {} }
	for k, party in pairs(parties) do
		party.id = k
		party.player = meta:get("player_" .. k)
		party.team = party.player and teams.get_by_player(party.player)
		party.tech = meta:get("tech_" .. k)
		party.accepted = meta:get_int("accept_" .. k) > 0
	end
	return parties
end

-- "name" == nil -> Update all open formspecs at "pos"
function barter_table.show_formspec(name, pos)
	if pos and name then
		barter_table.positions[name] = pos
	end
	pos = pos or barter_table.positions[name]
	assert(pos)

	if not name then
		for player_name, table_pos in pairs(barter_table.positions) do
			if vector.equals(pos, table_pos) then
				barter_table.show_formspec(player_name, pos)
			end
		end
		return
	end

	local team = teams.get_by_player(name)
	local parties = barter_table.get_parties(pos)

	local fs = {
		"size[10,7]"
	}

	local techs = ctw_technologies._get_technologies()
	local c = minetest.colorize

	local x = 0
	for k, p in pairs(parties) do
		local team_techs = {}
		for id, tech in pairs(techs) do
			if p.team and ctw_technologies.is_tech_gained(id, p.team) then
				table.insert(team_techs, {
					id, ctw_technologies.get_technology(id).name })
			end
		end
		if not p.player then
			-- Join formspec
			fs[#fs + 1] = ("button[%f,2;3,1;join_%s;Join]"):format(x + 0.5, k)
		else
			-- Barter formspec
			fs[#fs + 1] = ("label[%i,0;Team %s\nPlayer %s]"):format(x,
				c(p.team.color, p.team.name), p.player)
			fs[#fs + 1] = ("list[nodemeta:%i,%i,%i;inv_%s;%i,1.5;4,1;]"):format(
				pos.x, pos.y, pos.z, k, x)
			fs[#fs + 1] = ("dropdown[%i,2.6;4;tech_%s;%s;%i]"):format(
					x, k, table.concat(techs, ','), 0)
			-- TODO tech dropdown
			-- TODO change to labels for the other team
			if p.team == team then
				if not p.accepted then
					fs[#fs + 1] = ("button[%f,3.5;3,1;confirm_%s;%s]"):format(x + 0.5,
						k, c("#4F4", "OK"))
				else
					fs[#fs + 1] = ("button[%f,3.5;3,1;abort_%s;%s]"):format(x + 0.5,
						k, c("#FF4", "Abort"))
				end
				fs[#fs + 1] = ("button[%f,4.5;2,1;leave_%s;Leave]"):format(x + 1, k)
			else
				fs[#fs + 1] = ("label[%f,3.5;%s]"):format(x + 0.5,
						c("#4F4", p.accepted and "Accepted" or "Open offer"))
			end
			fs[#fs + 1] = ("list[current_player;main;1,6.2;8,1;]"):format(x + 1, k)
		end
		x = x + 6
	end
	if parties.a.accepted and parties.b.accepted then
		fs[#fs + 1] = ("button[3.5,4;3,1;exchange_%s;%s]"):format(
			parties.a.player == name and "a" or "b", c("#99F", "Exchange"))
	end
	minetest.show_formspec(name, "barter_table:formspec", table.concat(fs))
end

local function allow_metadata(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local parties = barter_table.get_parties(pos, meta)
	local party = parties[listname:match("_(.*)")]

	if party.player ~= player:get_player_name() then
		return 0
	end
	local update_formspec = false
	-- Conditions changed
	for k, p in pairs(parties) do
		if p.accepted then
			p.accepted = false
			update_formspec = true
		end
	end
	if update_formspec then
		barter_table.show_formspec(nil, pos)
	end
	return stack:get_count()
end

minetest.register_node("barter_table:table", {
	drawtype = "nodebox",
	description = "Barter Table",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = { "barter_top.png", "barter_base.png", "barter_side.png" },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5,0.3125,-0.5,0.5,0.5,0.5},
			{-0.4375,-0.5,-0.4375,-0.25,0.4,-0.25},
			{-0.4375,-0.5,0.25,-0.25,0.4,0.4375},
			{0.25,-0.5,-0.4375,0.4375,0.4,-0.25},
			{0.25,-0.5,0.25,0.4375,0.4,0.4475},
		},
	},
	groups = {choppy=2,oddly_breakable_by_hand=2},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("inv_a", 4)
		inv:set_size("inv_b", 4)
		barter_table.meta_reset(meta, "a")
		barter_table.meta_reset(meta, "b")

		meta:set_string("infotext", "Barter Table")
	end,
	on_rightclick = function(pos, node, clicker, _, _)
		local name = clicker:get_player_name()
		barter_table.show_formspec(name, pos)
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return from_list == to_list and count or 0
	end,
	allow_metadata_inventory_put = allow_metadata,
	allow_metadata_inventory_take = allow_metadata,
})
