local _queue = {}
local _cur_time = 0
local _next_dispatch = 100000000000

-- Runs a job. Doesn't remove it from queue.
local function dispatch(job)
	local suc, msg = pallets.deliver(job.tname, job.item)
	if msg then
		minetest.log(suc and "info" or "error", msg)
	end
	return suc
end

-- Checks for expired jobs, and dispatches them.
local function check_all()
	_next_dispatch = 100000000000

	local j=0
	for i=1, #_queue do
		local job = _queue[i]
		if job.time < _cur_time and dispatch(job) then
			_queue[i] = nil
		else
			if job.time < _next_dispatch then
				_next_dispatch = job.time
			end

			j = j + 1
			_queue[j] = job
		end
	end

	for i=j+1, #_queue do
		_queue[i] = nil
	end
end

function ctw_technologies.queue_delivery(tname, item, time)
	item = ItemStack(item)
	local stackdef = minetest.registered_items[item:get_name()]
	local desc = stackdef and stackdef.description or item:get_name()
	teams.chat_send_team(tname, "A shipment of " .. desc .. " will arrive in " .. math.floor(time) .. " seconds")

	time = time + _cur_time
	table.insert(_queue, {
		tname = tname,
		item = ItemStack(item),
		time = time,
	})

	if time < _next_dispatch then
		_next_dispatch = time
	end
end

minetest.register_globalstep(function(dtime)
	_cur_time = _cur_time + dtime
	if _cur_time < _next_dispatch then
		return
	end

	check_all()
end)
