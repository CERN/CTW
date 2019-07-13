reseau.era = {}
reseau.era.db = {}

reseau.era.default = {
	name = "default",
	tape_capacity = 500, -- tape capacity in MB
	dp_multiplier = 1, -- discovery points per delivered MB
	experiment_throughput_limit = 10, -- experiment data generation speed in MB/s
	router_throughput_limit = 20, -- router cache in MB/s
	receiver_throughput_limit = 10 -- throughput limit of receiver
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
		if ((type(era.startyear) == "boolean" and era.startyear == true) or year >= era.startyear)
		and ((type(era.endyear) == "boolean" and era.endyear == true) or year < era.endyear)  then
			return era.definition
		end
	end

	-- This should never happen
	minetest.log("error", "Reseau: could not get era, using default instead")
	return reseau.era.default
end

reseau.era.get_current = function()
	return reseau.era.get(year.get())
end

-- Notify players when new era is entered
-- Do this on globalstep since we don't care about single teams entering a different
-- year, but only about the *best* team.
minetest.register_globalstep(function(dtime)
	local last_era = reseau.db.last_era or reseau.era.default.name
	local current_era = reseau.era.get_current()

	if last_era == current_era.name then
		return
	end
	local msgs = {
		"All teams just entered the "..current_era.name.." era! Technological progress:",
		"* Tapes now have a capacity of "..current_era.tape_capacity.." MB",
		"* Experiments now generate data at a base rate of "..current_era.experiment_throughput_limit.." MB/s",
		"* Routers now have a base throughput limit of "..current_era.router_throughput_limit.." MB/s",
		"* Receivers now have a base processing throughput limit of "..current_era.receiver_throughput_limit.." MB/s",
		"* Every MB of transmitted data will earn you "..current_era.dp_multiplier.." discovery point(s)!"
	}

	for i, msg in ipairs(msgs) do
		minetest.chat_send_all(minetest.colorize("#0000a0", msg))
	end
	reseau.db.last_era = current_era.name
	reseau.db_commit()
end)
