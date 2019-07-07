
local S = homedecor.gettext

-- vectors to place one node next to or behind another

homedecor.fdir_to_right = {
	{  1,  0 },
	{  0, -1 },
	{ -1,  0 },
	{  0,  1 },
}

homedecor.fdir_to_left = {
	{ -1,  0 },
	{  0,  1 },
	{  1,  0 },
	{  0, -1 },
}

homedecor.fdir_to_fwd = {
	{  0,  1 },
	{  1,  0 },
	{  0, -1 },
	{ -1,  0 },
}

-- special case for wallmounted nodes

homedecor.wall_fdir_to_right = {
	nil,
	nil,
	{ -1,  0 },
	{  1,  0 },
	{  0, -1 },
	{  0,  1 },
}

homedecor.wall_fdir_to_left = {
	nil,
	nil,
	{  1,  0 },
	{ -1,  0 },
	{  0,  1 },
	{  0, -1 },
}

homedecor.wall_fdir_to_fwd = {
	nil,
	nil,
	{  0, -1 },
	{  0,  1 },
	{  1,  0 },
	{ -1,  0 },
}

local placeholder_node = "air"
minetest.register_alias("homedecor:expansion_placeholder", "air")

--- select which node was pointed at based on it being known, not ignored, buildable_to
-- returns nil if no node could be selected
local function select_node(pointed_thing)
	local pos = pointed_thing.under
	local node = minetest.get_node_or_nil(pos)
	local def = node and minetest.registered_nodes[node.name]

	if not def or not def.buildable_to then
		pos = pointed_thing.above
		node = minetest.get_node_or_nil(pos)
		def = node and minetest.registered_nodes[node.name]
	end
	return def and pos, def
end

--- check if all nodes can and may be build to
local function is_buildable_to(placer_name, ...)
	for _, pos in ipairs({...}) do
		local node = minetest.get_node_or_nil(pos)
		local def = node and minetest.registered_nodes[node.name]
		if not (def and def.buildable_to) or minetest.is_protected(pos, placer_name) then
			return false
		end
	end
	return true
end

-- place one or two nodes if and only if both can be placed
local function stack(itemstack, placer, fdir, pos, def, pos2, node1, node2, pointed_thing)
	local placer_name = placer:get_player_name() or ""
	if is_buildable_to(placer_name, pos, pos2) then
		local lfdir = fdir or minetest.dir_to_facedir(placer:get_look_dir())
		minetest.set_node(pos, { name = node1, param2 = lfdir })
		node2 = node2 or "air" -- this can be used to clear buildable_to nodes even though we are using a multinode mesh
		-- do not assume by default, as we still might want to allow overlapping in some cases
		local has_facedir = node2 ~= "air"
		if node2 == "placeholder" then
			has_facedir = false
			node2 = placeholder_node
		end
		minetest.set_node(pos2, { name = node2, param2 = (has_facedir and lfdir) or nil })

		-- call after_place_node of the placed node if available
		local ctrl_node_def = minetest.registered_nodes[node1]
		if ctrl_node_def and ctrl_node_def.after_place_node then
			ctrl_node_def.after_place_node(pos, placer, itemstack, pointed_thing)
		end

		if not creative.is_enabled_for(placer_name) then
			itemstack:take_item()
		end
	end
	return itemstack
end

local function rightclick_pointed_thing(pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node_or_nil(pos)
	if not node then return false end
	local def = minetest.registered_nodes[node.name]
	if not def or not def.on_rightclick then return false end
	return def.on_rightclick(pos, node, placer, itemstack, pointed_thing) or itemstack
end

-- Stack one node above another
-- leave the last argument nil if it's one 2m high node
function homedecor.stack_vertically(itemstack, placer, pointed_thing, node1, node2)
	local rightclick_result = rightclick_pointed_thing(pointed_thing.under, placer, itemstack, pointed_thing)
	if rightclick_result then return rightclick_result end

	local pos, def = select_node(pointed_thing)
	if not pos then return itemstack end

	local top_pos = { x=pos.x, y=pos.y+1, z=pos.z }

	return stack(itemstack, placer, nil, pos, def, top_pos, node1, node2, pointed_thing)
end

-- Stack one door node above another
-- like  homedecor.stack_vertically but tests first if it was placed as a right wing, then uses node1_right and node2_right instead

function homedecor.stack_wing(itemstack, placer, pointed_thing, node1, node2, node1_right, node2_right)
	local rightclick_result = rightclick_pointed_thing(pointed_thing.under, placer, itemstack, pointed_thing)
	if rightclick_result then return rightclick_result end

	local pos, def = select_node(pointed_thing)
	if not pos then return itemstack end

	local forceright = placer:get_player_control()["sneak"]
	local fdir = minetest.dir_to_facedir(placer:get_look_dir())

	local is_right_wing = node1 == minetest.get_node({ x = pos.x + homedecor.fdir_to_left[fdir+1][1], y=pos.y, z = pos.z + homedecor.fdir_to_left[fdir+1][2] }).name
	if forceright or is_right_wing then
		node1, node2 = node1_right, node2_right
	end

	local top_pos = { x=pos.x, y=pos.y+1, z=pos.z }
	return stack(itemstack, placer, fdir, pos, def, top_pos, node1, node2, pointed_thing)
end

function homedecor.stack_sideways(itemstack, placer, pointed_thing, node1, node2, dir)
	local rightclick_result = rightclick_pointed_thing(pointed_thing.under, placer, itemstack, pointed_thing)
	if rightclick_result then return rightclick_result end

	local pos, def = select_node(pointed_thing)
	if not pos then return itemstack end

	local fdir = minetest.dir_to_facedir(placer:get_look_dir())
	local fdir_transform = dir and homedecor.fdir_to_right or homedecor.fdir_to_fwd

	local pos2 = { x = pos.x + fdir_transform[fdir+1][1], y=pos.y, z = pos.z + fdir_transform[fdir+1][2] }

	return stack(itemstack, placer, fdir, pos, def, pos2, node1, node2, pointed_thing)
end

function homedecor.bed_expansion(pos, placer, itemstack, pointed_thing, trybunks)

	local thisnode = minetest.get_node(pos)
	local param2 = thisnode.param2
	local fdir = param2 % 8

	local fxd = homedecor.wall_fdir_to_fwd[fdir+1][1]
	local fzd = homedecor.wall_fdir_to_fwd[fdir+1][2]

	local forwardpos = {x=pos.x+fxd, y=pos.y, z=pos.z+fzd}
	local forwardnode = minetest.get_node(forwardpos)

	local def = minetest.registered_nodes[forwardnode.name]
	local placer_name = placer:get_player_name()

	if not (def and def.buildable_to) then
		minetest.chat_send_player( placer:get_player_name(),
				S("Not enough room - the space for the headboard is occupied!"))
		minetest.set_node(pos, {name = "air"})
		return true
	end

	if minetest.is_protected(forwardpos, placer_name) then
		minetest.chat_send_player( placer:get_player_name(),
				S("Someone already owns the spot where the headboard goes."))
		return true
	end

	minetest.set_node(forwardpos, {name = "air"})

	local lxd = homedecor.wall_fdir_to_left[fdir+1][1]
	local lzd = homedecor.wall_fdir_to_left[fdir+1][2]
	local leftpos = {x=pos.x+lxd, y=pos.y, z=pos.z+lzd}
	local leftnode = minetest.get_node(leftpos)

	local rxd = homedecor.wall_fdir_to_right[fdir+1][1]
	local rzd = homedecor.wall_fdir_to_right[fdir+1][2]
	local rightpos = {x=pos.x+rxd, y=pos.y, z=pos.z+rzd}
	local rightnode = minetest.get_node(rightpos)

	local inv = placer:get_inventory()

	if leftnode.name == "homedecor:bed_regular" then
		local newname = string.gsub(thisnode.name, "_regular", "_kingsize")
		local meta = minetest.get_meta(pos)
		local leftmeta = minetest.get_meta(leftpos)

		minetest.set_node(pos, {name = "air"})
		minetest.swap_node(leftpos, { name = newname, param2 = param2})
	elseif rightnode.name == "homedecor:bed_regular" then
		local newname = string.gsub(thisnode.name, "_regular", "_kingsize")
		local meta = minetest.get_meta(pos)
		local rightmeta = minetest.get_meta(rightpos)

		minetest.set_node(rightpos, {name = "air"})
		minetest.swap_node(pos, { name = newname, param2 = param2})
	end

	local toppos = {x=pos.x, y=pos.y+1.0, z=pos.z}
	local topposfwd = {x=toppos.x+fxd, y=toppos.y, z=toppos.z+fzd}

	if trybunks and is_buildable_to(placer_name, toppos, topposfwd) then
		local newname = string.gsub(thisnode.name, "_regular", "_extended")
		local newparam2 = param2 % 8
		minetest.swap_node(toppos, { name = thisnode.name, param2 = param2})
		minetest.swap_node(pos, { name = newname, param2 = param2})
		itemstack:take_item()
	end
end

function homedecor.unextend_bed(pos)
	local bottomnode = minetest.get_node({x=pos.x, y=pos.y-1.0, z=pos.z})
	local param2 = bottomnode.param2
	if bottomnode.name == "homedecor:bed_extended" then
		local newname = string.gsub(bottomnode.name, "_extended", "_regular")
		minetest.swap_node({x=pos.x, y=pos.y-1.0, z=pos.z}, { name = newname, param2 = param2})
	end
end

function homedecor.place_banister(itemstack, placer, pointed_thing)
	local rightclick_result = rightclick_pointed_thing(pointed_thing.under, placer, itemstack, pointed_thing)
	if rightclick_result then return rightclick_result end

	local pos, _ = select_node(pointed_thing)
	if not pos then return itemstack end

	local fdir = minetest.dir_to_facedir(placer:get_look_dir())
	local meta = itemstack:get_meta()
	local pindex = meta:get_int("palette_index")

	local abovepos  = { x=pos.x, y=pos.y+1, z=pos.z }
	local abovenode = minetest.get_node(abovepos)

	local adef = minetest.registered_nodes[abovenode.name]
	local placer_name = placer:get_player_name()

	if not (adef and adef.buildable_to) then
		minetest.chat_send_player(placer_name, S("Not enough room - the upper space is occupied!" ))
		return itemstack
	end

	if minetest.is_protected(abovepos, placer_name) then
		minetest.chat_send_player(placer_name, S("Someone already owns that spot."))
		return itemstack
	end

	local lxd = homedecor.fdir_to_left[fdir+1][1]
	local lzd = homedecor.fdir_to_left[fdir+1][2]

	local rxd = homedecor.fdir_to_right[fdir+1][1]
	local rzd = homedecor.fdir_to_right[fdir+1][2]

	local fxd = homedecor.fdir_to_fwd[fdir+1][1]
	local fzd = homedecor.fdir_to_fwd[fdir+1][2]

	local below_pos =           { x=pos.x, y=pos.y-1, z=pos.z }
	local fwd_pos =             { x=pos.x+fxd, y=pos.y, z=pos.z+fzd }
	local left_pos =            { x=pos.x+lxd, y=pos.y, z=pos.z+lzd }
	local right_pos =           { x=pos.x+rxd, y=pos.y, z=pos.z+rzd }
	local left_fwd_pos =        { x=pos.x+lxd+fxd, y=pos.y, z=pos.z+lzd+fzd  }
	local right_fwd_pos =       { x=pos.x+rxd+fxd, y=pos.y, z=pos.z+rzd+fzd  }
	local right_fwd_above_pos = { x=pos.x+rxd+fxd, y=pos.y+1, z=pos.z+rzd+fzd }
	local left_fwd_above_pos =  { x=pos.x+lxd+fxd, y=pos.y+1, z=pos.z+lzd+fzd }
	local right_fwd_below_pos = { x=pos.x+rxd+fxd, y=pos.y-1, z=pos.z+rzd+fzd }
	local left_fwd_below_pos =  { x=pos.x+lxd+fxd, y=pos.y-1, z=pos.z+lzd+fzd }

	local below_node =           minetest.get_node(below_pos)
	--local fwd_node =             minetest.get_node(fwd_pos)
	local left_node =            minetest.get_node(left_pos)
	local right_node =           minetest.get_node(right_pos)
	local left_fwd_node =        minetest.get_node(left_fwd_pos)
	local right_fwd_node =        minetest.get_node(right_fwd_pos)
	local left_below_node =      minetest.get_node({x=left_pos.x, y=left_pos.y-1, z=left_pos.z})
	local right_below_node =     minetest.get_node({x=right_pos.x, y=right_pos.y-1, z=right_pos.z})
	--local right_fwd_above_node = minetest.get_node(right_fwd_above_pos)
	--local left_fwd_above_node =  minetest.get_node(left_fwd_above_pos)
	local right_fwd_below_node = minetest.get_node(right_fwd_below_pos)
	local left_fwd_below_node =  minetest.get_node(left_fwd_below_pos)

	local new_place_name = itemstack:get_name()

	-- try to place a diagonal one on the side of blocks stacked like stairs
	-- or follow an existing diagonal with another.
	if (left_below_node and string.find(left_below_node.name, "banister_.-_diagonal_right")
	  and below_node and is_buildable_to(placer_name, below_pos, below_pos))
	  or not is_buildable_to(placer_name, right_fwd_above_pos, right_fwd_above_pos) then
		new_place_name = string.gsub(new_place_name, "_horizontal", "_diagonal_right")
	elseif (right_below_node and string.find(right_below_node.name, "banister_.-_diagonal_left")
	  and below_node and is_buildable_to(placer_name, below_pos, below_pos))
	  or not is_buildable_to(placer_name, left_fwd_above_pos, left_fwd_above_pos) then
		new_place_name = string.gsub(new_place_name, "_horizontal", "_diagonal_left")

	-- try to follow a diagonal with the corresponding horizontal
	-- from the top of a diagonal...
	elseif left_below_node and string.find(left_below_node.name, "homedecor:banister_.*_diagonal") then
		fdir = left_below_node.param2
		new_place_name = string.gsub(left_below_node.name, "_diagonal_.-$", "_horizontal")
	elseif right_below_node and string.find(right_below_node.name, "homedecor:banister_.*_diagonal") then
		fdir = right_below_node.param2
		new_place_name = string.gsub(right_below_node.name, "_diagonal_.-$", "_horizontal")

	-- try to place a horizontal in-line with the nearest diagonal, at the top
	elseif left_fwd_below_node and string.find(left_fwd_below_node.name, "homedecor:banister_.*_diagonal")
	  and is_buildable_to(placer_name, fwd_pos, fwd_pos) then
		fdir = left_fwd_below_node.param2
		pos = fwd_pos
		new_place_name = string.gsub(left_fwd_below_node.name, "_diagonal_.-$", "_horizontal")
	elseif right_fwd_below_node and string.find(right_fwd_below_node.name, "homedecor:banister_.*_diagonal")
	  and is_buildable_to(placer_name, fwd_pos, fwd_pos) then
		fdir = right_fwd_below_node.param2
		pos = fwd_pos
		new_place_name = string.gsub(right_fwd_below_node.name, "_diagonal_.-$", "_horizontal")

	-- try to follow a diagonal with a horizontal, at the bottom of the diagonal
	elseif left_node and string.find(left_node.name, "homedecor:banister_.*_diagonal") then
		fdir = left_node.param2
		new_place_name = string.gsub(left_node.name, "_diagonal_.-$", "_horizontal")
	elseif right_node and string.find(right_node.name, "homedecor:banister_.*_diagonal") then
		fdir = right_node.param2
		new_place_name = string.gsub(right_node.name, "_diagonal_.-$", "_horizontal")

	-- try to place a horizontal in-line with the nearest diagonal, at the bottom
	elseif left_fwd_node and string.find(left_fwd_node.name, "homedecor:banister_.*_diagonal")
	  and is_buildable_to(placer_name, fwd_pos, fwd_pos) then
		fdir = left_fwd_node.param2
		pos = fwd_pos
		new_place_name = string.gsub(left_fwd_node.name, "_diagonal_.-$", "_horizontal")
	elseif right_fwd_node and string.find(right_fwd_node.name, "homedecor:banister_.*_diagonal")
	  and is_buildable_to(placer_name, fwd_pos, fwd_pos) then
		fdir = right_fwd_node.param2
		pos = fwd_pos
		new_place_name = string.gsub(right_fwd_node.name, "_diagonal_.-$", "_horizontal")
	end

	-- manually invert left-right orientation
	if placer:get_player_control()["sneak"] then
		if string.find(new_place_name, "banister_.*_diagonal") then
			new_place_name = string.gsub(new_place_name, "_left", "_right")
		else
			new_place_name = string.gsub(new_place_name, "_right", "_left")
		end
	end

	minetest.set_node(pos, {name = new_place_name, param2 = fdir+pindex})
	itemstack:take_item()
	return itemstack
end
