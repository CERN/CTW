local _registered_on_change = {}
local START_YEAR = 1983
local END_YEAR = 1994
local _year = START_YEAR

function year.get(team)
	if team then
		if type(team) == "string" then
			team = teams.get(team)
		end
		return team.year or START_YEAR
	else
		return _year
	end
end

function year.get_range()
	return START_YEAR, END_YEAR
end

function year.register_on_change(func)
	table.insert(_registered_on_change, func)
end

function year.set(v, tname)
	_year = v

	local team = teams.get(tname)
	team.year = v

	for i=1, #_registered_on_change do
		_registered_on_change[i](v, tname)
	end
end

function year.bump(v, tname)
	if v > _year then
		year.set(v, tname)
	end
end
