-- please keep any non-generic nodeboxe with its node definition
-- this file should not accumulate any left over nodeboxes
-- but is meant to host any abstractions or calculations based on nodeboxes

-- a box is defined as {x1, y1, z1, x2, y2, z2}
homedecor.box = {
	-- slab starting from -x (after rotation: left)
	slab_x = function(depth) return { -0.5, -0.5, -0.5, -0.5+depth, 0.5, 0.5 } end,
	-- bottom slab (starting from -y) with height optionally shifted upwards
	slab_y = function(height, shift) return { -0.5, -0.5+(shift or 0), -0.5, 0.5, -0.5+height+(shift or 0), 0.5 } end,
	-- slab starting from -z (+z with negative depth)
	slab_z = function(depth)
		-- for consistency with the other functions here, we have to assume that a "z" slab starts from -z and extends by depth,
		-- but since conventionally a lot of nodes place slabs against +z for player convenience, we define
		-- a "negative" depth as a depth extending from the other side, i.e. +z
		if depth > 0 then
			-- slab starting from -z
			return { -0.5, -0.5, -0.5, 0.5, 0.5, -0.5+depth }
		else
			-- slab starting from +z (z1=0.5-(-depth))
			return { -0.5, -0.5, 0.5+depth, 0.5, 0.5, 0.5 }
		end
	end,
	bar_y = function(radius) return {-radius, -0.5, -radius, radius, 0.5, radius} end,
	cuboid = function(radius_x, radius_y, radius_z) return {-radius_x, -radius_y, -radius_z, radius_x, radius_y, radius_z} end,
}

homedecor.nodebox = {
	-- { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
	-- can be used in-place as:
	-- { type="regular" },
	regular = { type="regular" },
	null = { type = "fixed", fixed = { 0, 0, 0, 0, 0, 0 } },
	corner_xz = function(depth_x, depth_z) return {
		type="fixed",
		fixed={
			homedecor.box.slab_x(depth_x),
			homedecor.box.slab_z(depth_z),
		-- { -0.5, -0.5, -0.5, 0.5-depth, 0.5, -0.5+depth } -- slab_x without the overlap, but actually looks a bit worse
		}
	} end,
}

local mt = {}
mt.__index = function(table, key)
	local ref = homedecor.box[key]
	local ref_type = type(ref)
	if ref_type == "function" then
		return function(...)
			return { type = "fixed", fixed = ref(...) }
		end
	elseif ref_type == "table" then
		return { type = "fixed", fixed = ref }
	elseif ref_type == "nil" then
		error(key .. "could not be found among nodebox presets and functions")
	end
	error("unexpected datatype " .. tostring(type(ref)) .. " while looking for " .. key)
end
setmetatable(homedecor.nodebox, mt)
