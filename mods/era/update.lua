-- Notify players when new era is entered
-- Do this on globalstep since we don't care about single teams entering a different
-- year, but only about the *best* team.
minetest.register_globalstep(function(dtime)
	local last_era = era.db.last_era or era.default.name
	local current_era = era.get_current()

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
	era.db.last_era = current_era.name
	era.db_commit()
end)
