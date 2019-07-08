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
		if year >= era.startyear and year < era.endyear then
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

	if last_era ~= current_era.name then
		local eramsg1 = "All teams just entered the "..current_era.name.." era! Technological progress:"
		local eramsg2 = "* Tapes now have a capacity of "..current_era.tape_capacity.." MB"
		local eramsg3 = "* Experiments now generate data at a base rate of "..current_era.experiment_throughput_limit.." MB/s"
		local eramsg4 = "* Routers now have a base throughput limit of "..current_era.router_throughput_limit.." MB/s"
		local eramsg5 = "* Receivers now have a base processing throughput limit of "..current_era.receiver_throughput_limit.." MB/s"
		local eramsg6 = "* Every MB of transmitted data will earn you "..current_era.dp_multiplier.." discovery point(s)!"

		minetest.chat_send_all(minetest.colorize("#0000a0", eramsg1))
		minetest.chat_send_all(minetest.colorize("#0000a0", eramsg2))
		minetest.chat_send_all(minetest.colorize("#0000a0", eramsg3))
		minetest.chat_send_all(minetest.colorize("#0000a0", eramsg4))
		minetest.chat_send_all(minetest.colorize("#0000a0", eramsg5))
		minetest.chat_send_all(minetest.colorize("#0000a0", eramsg6))
		reseau.db.last_era = current_era.name
		reseau.db_commit()
	end
end)
