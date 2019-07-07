reseau.era = {}
reseau.era.db = {}

reseau.era.default = {
	genspeed = 10, -- experiment data generation speed in MB/s
	tape_capacity = 500, -- tape capacity in MB
	dp_multiplier = 1, -- discovery points per delivered MB
	router_max_cache = 60, -- router cache in MB
	receiver_throughput = 10 -- throughput limit of receiver
}

-- set startyear / endyear to true to mean +infinity / -infinity respectively
reseau.era.register = function(startyear, endyear, definition)
	table.insert(reseau.era.db, {
		startyear = startyear,
		endyear = endyear,
		definition = definition
	})
end

reseau.era.get = function(year)
	for _, era in ipairs(reseau.era.db) do
		print(dump(year))
		print(dump(era.startyear))
		if ((type(era.startyear) == "boolean" and era.startyear == true) or year >= era.startyear)
		and ((type(era.endyear) == "boolean" and era.endyear == true) or year < era.endyear)  then
			return era.definition
		end
	end

	-- This should never happen
	return reseau.era.default
end

reseau.era.get_current = function()
	return reseau.era.get(year.get())
end
