-- set startyear / endyear to true to mean +infinity / -infinity respectively
era.register = function(startyear, endyear, definition)
	table.insert(era.definitions, {
		startyear = startyear,
		endyear = endyear,
		definition = definition
	})
end

era.get = function(year)
	for _, era in ipairs(era.definitions) do
		if ((type(era.startyear) == "boolean" and era.startyear == true) or year >= era.startyear)
		and ((type(era.endyear) == "boolean" and era.endyear == true) or year < era.endyear)  then
			return era.definition
		end
	end

	-- This should never happen
	minetest.log("error", "Era: could not get era, using default instead")
	return era.default
end

era.get_current = function()
	return era.get(year.get())
end
