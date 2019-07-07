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
		minetest.chat_send_player(pname, "-!- Team '"..tname"' does not exist!")
		return
	end

	-- create inventory if not exists
	local inv = team_billboard.get_billboard_inventory(team, false)

	local form = {
		"size[10,9]",
		"label[0,0;== TEAM BILLBOARD ==",
		"Put any ideas here to share them with your team!",
		"Once you have collected references and gotten",
		"permission from the management, put the",
		"approval letter here to start prototyping the idea!]",
		"list[detached:team_billboard_" .. tname .. ";ideas;0,2.5;1,5;]",
		"list[detached:team_billboard_" .. tname .. ";approvals;4,2.5;1,5;]",
		"list[current_player;main;0,8;8,1;]" }
	-- Put buttons next to the ideas with links to doc pages
	local ilist = inv:get_list("ideas")

	if pers_msg then
		table.insert(form, "label[0,2;"..pers_msg.."]")
	end
	table.insert(form, "button[6.5,0;3.5,1;doc;View knowledge base]")

	for index, item in ipairs(ilist) do
		if minetest.get_item_group(item:get_name(), "ctw_idea") > 0 then
			local idef = minetest.registered_items[item:get_name()]
			local idea_id = idef._ctw_idea_id
			if idea_id then
				local idea = ctw_resources.get_idea(idea_id)
				local istate = ctw_resources.get_team_idea_state(idea_id, team)
				table.insert(form, "button[1,"..(1.5 + index)..";3,1;idea_"..idea_id..";"..idea.name.."]")
				if istate.state == "inventing" then
					local total = idea.invention_dp
					local have = istate.target
					local percent = math.floor(100 * (have/total))
					table.insert(form, "label[5,"..(1.5 + index)..";Prototyping "..percent.."% ("..have.."/"..total.." DP)]")
				end
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
	if formname == "team_billboard:bb" then
		local team = teams.get_by_player(pname)
		if not team then return end
		local tname = team.name
		if fields.quit then
			open_forms[tname][pname] = nil
			return
		end
		if fields.doc then
			open_forms[tname][pname] = nil
			doc.show_doc(pname)
			return
		end
		for field, _ in pairs(fields) do
			local idea_id = string.match(field, "^idea_(.+)$")
			if idea_id then
				doc.show_entry(pname, "ctw_ideas", idea_id)
				return
			end
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
