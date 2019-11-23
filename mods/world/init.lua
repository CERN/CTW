world = {}

dofile(minetest.get_modpath("world") .. "/api.lua")
dofile(minetest.get_modpath("world") .. "/sounds.lua")

if minetest.get_modpath("teams") then
	dofile(minetest.get_modpath("world") .. "/emerge.lua")
else
	minetest.chat_send_all("** WORLD BUILDER MODE **")
	dofile(minetest.get_modpath("world") .. "/builder.lua")
	dofile(minetest.get_modpath("world") .. "/builder_nodes.lua")
end

function world.teleport_to_spawn(player)
	local team = teams and teams.get_by_player(player)
	local spawn
	if team then
		spawn = world.get_team_location(team.name, "spawn")
	else
		spawn = world.get_location("spawn")
	end

	if spawn then
		player:set_pos(spawn)
	end
end

minetest.register_on_newplayer(world.teleport_to_spawn)
minetest.register_on_respawnplayer(world.teleport_to_spawn)

minetest.register_chatcommand("spawn", {
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			world.teleport_to_spawn(player)
		end
	end,
})

minetest.register_alias("lapis:lapisblock", "default:dirt_with_grass")
minetest.register_alias("ferns:tree_fern_leaves", "air")
