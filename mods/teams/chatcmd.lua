local S = minetest.get_translator("teams")

ChatCmdBuilder.new("team", function(cmd)
	cmd:sub("list", function(name)
		local retval = {}

		local list = teams.get_all()
		for i=1, #list do
			local def = list[i]
			retval[#retval + 1] = S("- @1", def.team_display_name)
		end

		if #list == 0 then
			return false, S("There are no teams")
		else
			return true, S("Teams:\n") .. table.concat(retval, "\n")
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
			return true, S("You are in @1", team.display_name)
		else
			return false, S("You are not a team")
		end
	end)
end)

minetest.register_chatcommand("join", {
	func = function(name, tname)
		tname = tname:trim()

		local player = minetest.get_player_by_name(name)
		if not player then
			return false, S("You must be online to change teams!")
		end

		if teams.get_by_player(player) then
			return false, S("You are already in a team!")
		end

		if teams.set_team(player, tname) then
			return true, S("Joined @1", teams.get(tname).display_name)
		else
			return false, S("No such team '@1'", tname)
		end
	end
})

minetest.register_chatcommand("t", {
	func = function(name, param)
		local team = teams.get_by_player(name)
		local message = ("%s <%s> %s"):format(
			minetest.colorize(team.color, "[Team only]"), name, param)
		teams.chat_send_team(team.name, message)
	end
})


local old_format = minetest.format_chat_message
minetest.format_chat_message = function(name, message)
	local team = teams.get_by_player(name)
	if not team then
		return old_format(name, message)
	end

	return minetest.colorize(team.color, "<" .. name .. ">") .. " " .. message
end
