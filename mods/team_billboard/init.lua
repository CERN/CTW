-- Craft The Web
-- Team Billboard: Central place where team members publish ideas and put approvals

team_billboard = {}

local mp = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM

dofile(mp.."inventory.lua")

local pos_setup = {}

local after_place_node = function(pos, player, itemstack, pointed_thing)
	local pname = player:get_player_name()
	pos_setup[pname] = pos
	minetest.show_formspec(pname, "team_billboard_setup_pos", "field[team;Team?;]")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	if formname == "team_billboard_setup_pos" and pos_setup[pname] and fields.team then
		local meta = minetest.get_meta(pos_setup[pname])
		meta:set_string("team", fields.team)
		pos_setup[pname] = nil
	end
end)

local open_forms = {}

local on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	local pname = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local tname = meta:get_string("team")
	if tname == "" then
		minetest.chat_send_player(pname, "-!- Metadata missing, re-place node!")
		return
	end
	team_billboard.show_billboard_form(pname, tname)
end

function team_billboard.show_billboard_form(pname, tname, pers_msg)
	local team = teams.get(tname)
	if not team then
		minetest.chat_send_player(pname, "-!- Team '"..tname.."' does not exist!")
		return
	end

	-- create inventory if not exists
	local inv = team_billboard.get_billboard_inventory(team, false)

	local tlocation = "detached:team_billboard_" .. tname
	local infotext = {
		"Put any ideas here to share them with your team!",
		"Once you have collected references and gotten",
		"permission from the management, put the",
		"approval letter here to start prototyping the idea!",
	}
	local form = {
		"size[10,9]",
		("textarea[0.2,0.2;6,2;;%s;%s]"):format(
			minetest.colorize(team.color, "== TEAM BILLBOARD =="),
			table.concat(infotext, " ")),
		"list[" .. tlocation .. ";ideas;1,2.5;1,5;]",
		"list[" .. tlocation .. ";approvals;6,2.5;1,5;]",
		"list[current_player;main;1,8;8,1;]",
		"listring[" .. tlocation .. ";approvals]",
		"listring[current_player;main]",
		"listring[" .. tlocation .. ";ideas]",
		"listring[current_player;main]",
	}
	-- Put buttons next to the ideas with links to doc pages
	local ilist = inv:get_list("ideas")

	local y = 2.5
	for _ in ipairs(ilist) do
		form[#form + 1] = "image[1," .. y .. ";1,1;team_billboard_idea.png]"
		form[#form + 1] = "image[6," .. y .. ";1,1;team_billboard_letter.png]"
		y = y + 1
	end

	if pers_msg then
		table.insert(form, "label[0,2;"..pers_msg.."]")
	end
	table.insert(form, "button[6.5,0.75;3.5,1;tech_tree;View Technology Tree]")

	for index, item in ipairs(ilist) do
		local idef = minetest.registered_items[item:get_name()]
		local idea_id = idef and idef._ctw_idea_id
		if idea_id then
			local idea = ctw_resources.get_idea(idea_id)
			local istate = ctw_resources.get_team_idea_state(idea_id, team)
			table.insert(form, "button[2,"..(1.5 + index)..";4,1;idea_"..idea_id..";"..idea.name.."]")
			if istate.state == "inventing" then
				-- Researching speed may change
				local percent = math.floor(100 * idea.have / idea.invention_dp)
				table.insert(form, "label[7,"..(1.5 + index)..";Prototyping "..percent.."%]")
			else
				table.insert(form, "label[7,"..(1.5 + index)..";State: "..istate.state.."]")
			end
		end
	end

	-- save in open_forms
	if not open_forms[tname] then
		open_forms[tname] = {}
	end
	open_forms[tname][pname] = true

	minetest.show_formspec(pname, "team_billboard:bb", table.concat(form, "\n"))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	if formname ~= "team_billboard:bb" then
		return
	end

	local team = teams.get_by_player(pname)
	if not team then return end
	local tname = team.name
	if not (open_forms[tname] and open_forms[tname][pname]) then
		return -- when opening other team's billboards
	end

	if fields.quit then
		open_forms[tname][pname] = nil
		return
	end
	if fields.tech_tree then
		open_forms[tname][pname] = nil
		ctw_technologies.form_returnstack_push(pname, function(pname2)
			team_billboard.show_billboard_form(pname2, tname)
		end)
		ctw_technologies.show_tech_tree(pname,0)
		return
	end

	for field, _ in pairs(fields) do
		local idea_id = string.match(field, "^idea_(.+)$")
		if idea_id then
			open_forms[tname][pname] = nil
			ctw_technologies.form_returnstack_push(pname, function(pname2)
				team_billboard.show_billboard_form(pname, tname2)
			end)
			ctw_resources.show_idea_form(pname, idea_id)
		end
	end

end)


function team_billboard.update_open_forms(tname, pers_to, pers_msg)
	if open_forms[tname] then
		for pname, _ in pairs(open_forms[tname]) do
			team_billboard.show_billboard_form(pname, tname, pname==pers_to and pers_msg)
		end
	end
end

ctw_resources.register_on_inventing_progress(function(team)
	team_billboard.update_open_forms(team.name)
end)

-- Node definition

minetest.register_node("team_billboard:bb", {
	description = "Team Billboard",
	drawtype = "signlike",
	visual_scale = 2.0,
	tiles = { "team_billboard_billboard.png" },
	inventory_image = "team_billboard_billboard.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 1, -- reflecting a bit of light might be expected
	selection_box = { type = "wallmounted" },
	groups = {attached_node=1},
	legacy_wallmounted = true,

	after_place_node = after_place_node,
	on_rightclick = on_rightclick,
})

local function sqdist(pos1, pos2)
	local delta = vector.subtract(pos1, pos2)
	return delta.x*delta.x + delta.y*delta.y + delta.z*delta.z
end

minetest.register_lbm({
	label = "Assign team to billboard",
	name = "team_billboard:teamise",
	nodenames = { "team_billboard:bb" },
	run_at_every_load = true,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		if meta:contains("team") then
			return
		end

		local min_team = nil
		local min_dist = 10000000

		for tname, _ in pairs(teams.get_dict()) do
			local pos2 = world.get_team_location(tname, "base")
			local dist = sqdist(pos, pos2)
			if dist < min_dist then
				min_team = tname
				min_dist = dist
			end
		end

		meta:set_string("team", min_team)
	end,
})
