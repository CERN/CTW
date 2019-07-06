ChatCmdBuilder.new("team", function(cmd)
	cmd:sub("list", function(name)
		local retval = {}

		local list = teams.get_all()
		for i=1, #list do
			local def = list[i]
			retval[#retval + 1] = ("- %s"):format(def.name)
		end

		if #list == 0 then
			return false, "There are no teams"
		else
			return true, "Teams:\n" .. table.concat(retval, "\n")
		end
	end)

	cmd:sub("dp :x:int", function(name, x)
		local tname = teams.get_by_player(name).name
		teams.add_points(tname, x)
	end)

	cmd:sub("dp :team :x:int", function(name, tname, x)
		teams.add_points(tname, x)
	end)

	cmd:sub("", function(name)
		local player = minetest.get_player_by_name(name)
		local team = teams.get_by_player(player)
		if team then
			return true, ("You are in team %s"):format(team.name)
		else
			return false, "You are not a team"
		end
	end)
end)

minetest.register_chatcommand("join", {
	func = function(name, tname)
		tname = tname:trim()

		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "You must be online to change teams!"
		end

		if teams.set_team(player, tname) then
			return true, "Joined " .. tname
		else
			return false, "No such team '" .. tname .. "'"
		end
	end
})

minetest.register_chatcommand("t", {
	func = function(name, param)
		local team = teams.get_by_player(name)
		local message = ("<%s> %s"):format(name, param)
		teams.chat_send_team(team.name, message)
	end
})
