reseau.tablecopy = function(t) -- deep table copy
	return type(t) ~= "table" and t or table.copy(t)
end

reseau.mergetable = function(source, dest)
	local rval = reseau.tablecopy(dest)

	for k, v in pairs(source) do
		rval[k] = dest[k] or reseau.tablecopy(v)
	end
	for i, v in ipairs(source) do
		table.insert(rval, reseau.tablecopy(v))
	end

	return rval
end

reseau.table_contains = function(table, content)
	for _, val in ipairs(table) do
		if val == content then
			return true
		end
	end

	return false
end

reseau.table_intersection = function(table1, table2)
	local intersection = {}

	for _, val in ipairs(table1) do
		if reseau.table_contains(table2, val) then
			table.insert(intersection, val)
		end
	end

	return intersection
end

function reseau.load_position(pos)
	if pos.x < -30912 or pos.y < -30912 or pos.z < -30912 or
	   pos.x >  30927 or pos.y >  30927 or pos.z >  30927 then return end
	if minetest.get_node_or_nil(pos) then
		return
	end
	local vm = minetest.get_voxel_manip()
	vm:read_from_map(pos, pos)
end

function reseau.with_overlay(base, color, overlay_name)
	return base .. "^(" .. overlay_name .. "^[multiply:" .. color .. ")"
end

function reseau.throughput_string(throughput)
	return string.format("%.1f", throughput)
end
