local function vadd(...)
	local arr = {...}
	local v = {
		x = arr[1].x + arr[2].x,
		y = arr[1].y + arr[2].y,
	}

	if #arr > 2 then
		for i=3, #arr do
			v.x = v.x + arr[i].x
			v.y = v.y + arr[i].y
		end
	end

	return v
end


local ProgressBar = {}
progressbar = {}
progressbar.ProgressBar = ProgressBar

function ProgressBar:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.hud = hudkit()
	obj.data = {}
	obj.offset = { x = 0, y = 20 }
	obj.width = 600
	obj.min = 0
	obj.max = 1000

	return obj
end

function ProgressBar:move_to(offset)
	self.offset = offset
	self:update_hud()
end

function ProgressBar:move(offset)
	self.offset = vadd(self.offset, offset)
	self:update_hud()
end

function ProgressBar:set_values(data)
	self.data = data

	local max_k, max_v
	for key, value in pairs(data) do
		if not max_v or value > max_v then
			max_k = key
			max_v = value
		end
	end

	self._leader = max_k

	self:update_hud()
end

function ProgressBar:update_hud()
	for _, player in pairs(minetest.get_connected_players()) do
		self:update_hud_for_player(player)
	end
end

function ProgressBar:calc_offset(value)
	local perc = (value - self.min) / (self.max - self.min)
	return vadd(self.offset, { x = (perc - 0.5) * self.width, y = 0 })
end

function ProgressBar:update_hud_for_player(player)
	local tname = teams.get_by_player(player)
	if tname then
		tname = tname.name
	end

	local hud = self.hud

	local _leader = self._leader or "blue"
	if not hud:exists(player, "bar") then
		hud:add(player, "bar", {
			hud_elem_type = "image",
			position      = {x = 0.5, y = 0},
			scale         = {x=self.width, y=1},
			text          = "year_track_" .. _leader .. ".png",
			offset        = self.offset,
			alignment     = { x = 0, y = 0 },
		})
	else
		hud:change(player, "bar", "text", "year_track_" .. _leader .. ".png")
		hud:change(player, "bar", "offset", self.offset)
	end

	for key, value in pairs(self.data) do
		local ele  = "year:" .. key

		local scale = {x = 1, y = 0.8, z = 0}
		if tname == key then
			scale =  {x = 1, y = 1.5, z = 0}
		end

		local offset = self:calc_offset(value)
		if not hud:exists(player, ele) then
			hud:add(player, ele, {
				hud_elem_type = "image",
				position      = { x = 0.5, y = 0 },
				scale         = scale,
				text          = "year_pip_" .. key .. ".png",
				offset        = offset,
				alignment     = { x = 0, y = 0 },
			})
		else
			hud:change(player, ele, "offset", offset)
			hud:change(player, ele, "scale", scale)
		end
	end

	local leader_pos = self.data[self._leader] or self.min
	local offset = vadd(self:calc_offset(leader_pos), { x = 0, y = 30 })
	if not hud:exists(player, "year:year") then
		hud:add(player, "year:year", {
			hud_elem_type = "text",
			position      = {x = 0.5, y = 0},
			scale         = { x = 100, y = 100},
			offset        = offset,
			text          = math.floor(leader_pos),
			number        = 0xFFFFFF,
			alignment     = {x = 0, y = 0},
		})
	else
		hud:change(player, "year:year", "offset", offset)
		hud:change(player, "year:year", "text", math.floor(leader_pos))
	end
end
