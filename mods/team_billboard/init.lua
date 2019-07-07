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

local on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	local pname = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local tname = meta:get_string("team")
	if tname == "" then
		minetest.chat_send_player(pname, "-!- Metadata missing, re-place node!")
		return
	end
	local team = teams.get(tname)
	if not team then
		minetest.chat_send_player(pname, "-!- Team '"..tname"' does not exist!")
		return
	end
	
	-- create inventory if not exists
	team_billboard.get_billboard_inventory(team, false)
	
	local form =
		"size[8,9]" ..
		"label[0,0;== TEAM BILLBOARD ==\n" ..
		"Put any ideas here to share them with your team!\n" ..
		"Once you have collected references and gotten\n" ..
		"permission from the management, put the\n" ..
		"approval letter here to start prototyping the idea!]"..
		"label[0,2.3;== IDEAS ==]"..
		"list[detached:team_billboard_" .. tname .. ";ideas;0,2.9;8,2;]" ..
		"label[0,5;== APPROVAL LETTERS ==]"..
		"list[detached:team_billboard_" .. tname .. ";approvals;0,5.6;8,2;]" ..
		"list[current_player;main;0,8;8,1;]"
	minetest.show_formspec(pname, "team_billboard:bb", form)
end


-- Node definition

minetest.register_node("team_billboard:bb", {
	description = "Team Billboard",
	drawtype = "signlike",
	visual_scale = 3.0,
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
