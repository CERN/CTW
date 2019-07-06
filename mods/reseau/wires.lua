-- naming scheme: wire:(xp)(zp)(xm)(zm)(xpyp)(zpyp)(xmyp)(zmyp)_on/off
-- where x= x direction, z= z direction, y= y direction, p = +1, m = -1, e.g. xpym = {x=1, y=-1, z=0}
-- The (xp)/(zpyp)/.. statements shall be replaced by either 0 or 1
-- Where 0 means the wire has no visual connection to that direction and
-- 1 means that the wire visually connects to that other node.

-- #######################
-- ## Update wire looks ##
-- #######################

-- does node at self_pos want to connect to node at from_pos?
local wire_getconnect = function(from_pos, self_pos, wire_name)
	local self_node = minetest.get_node(self_pos)
	local self_nodespec = minetest.registered_nodes[self_node.name]
	if not reseau.technologies_compatible(wire_name, self_node.name) then
		return false
	end
	local wire_nodespec = minetest.registered_nodes[wire_name]
	if self_nodespec and wire_nodespec
			and self_nodespec.team_name and wire_nodespec.team_name
			and self_nodespec.team_name ~= wire_nodespec.team_name then
		return false
	end

	if self_nodespec and self_nodespec.reseau then
		local rules
		if self_nodespec.is_reseau_wire then
			rules = reseau.rules.default
		else
			rules = reseau.get_any_rules(self_pos)
		end

		for _, r in ipairs(rules) do
			if vector.equals(vector.add(self_pos, r), from_pos) then
				return true
			end
		end
	end
	return false
end

-- Update this node
local wire_updateconnect = function(pos)
	local wire_name = minetest.get_node(pos).name
	local basename = minetest.registered_nodes[wire_name].reseau.conductor.basename

	local connections = {}

	for _, r in ipairs(reseau.rules.default) do
		if wire_getconnect(pos, vector.add(pos, r), wire_name) then
			table.insert(connections, r)
		end
	end

	-- Wire may only have two connections at max (no T-pieces / crossings):
	-- Truncate connections table to two connections
	while #connections > 2 do
		table.remove(connections, 1)
	end

	local nid = {}
	for _, vec in ipairs(connections) do
		-- flat component
		if vec.x ==  1 then nid[0] = "1" end
		if vec.z ==  1 then nid[1] = "1" end
		if vec.x == -1 then nid[2] = "1" end
		if vec.z == -1 then nid[3] = "1"  end

		-- slopy component
		if vec.y == 1 then
			if vec.x ==  1 then nid[4] = "1" end
			if vec.z ==  1 then nid[5] = "1" end
			if vec.x == -1 then nid[6] = "1" end
			if vec.z == -1 then nid[7] = "1" end
		end
	end

	local nodeid = (nid[0] or "0")..(nid[1] or "0")..(nid[2] or "0")..(nid[3] or "0")
			..(nid[4] or "0")..(nid[5] or "0")..(nid[6] or "0")..(nid[7] or "0")

	minetest.set_node(pos, {name = "reseau:"..basename.."_wire_"..nodeid})
end


local update_on_place_dig = function(pos, node)
	-- Update placed node (get_node again as it may have been dug)
	local nn = minetest.get_node(pos)
	if (minetest.registered_nodes[nn.name]) and (minetest.registered_nodes[nn.name].is_reseau_wire) then
		wire_updateconnect(pos)
	end

	-- Update nodes around it
	for _, r in ipairs(reseau.rules.default) do
		local np = vector.add(pos, r)
		local nodespec = minetest.registered_nodes[minetest.get_node(np).name]
		if nodespec and nodespec.is_reseau_wire then
			wire_updateconnect(np)
		end
	end
end

minetest.register_on_placenode(update_on_place_dig)
minetest.register_on_dignode(update_on_place_dig)


-- ############################
-- ## Wire node registration ##
-- ############################
-- Nodeboxes:
local box_center = {-1/16, -.5, -1/16, 1/16, -.5+1/16, 1/16}

local nbox_nid =
{
	[0] = {1/16, -.5, -1/16, 8/16, -.5+1/16, 1/16}, -- x positive
	[1] = {-1/16, -.5, 1/16, 1/16, -.5+1/16, 8/16}, -- z positive
	[2] = {-8/16, -.5, -1/16, -1/16, -.5+1/16, 1/16}, -- x negative
	[3] = {-1/16, -.5, -8/16, 1/16, -.5+1/16, -1/16}, -- z negative

	[4] = {.5-1/16, -.5+1/16, -1/16, .5, .4999+1/16, 1/16}, -- x positive up
	[5] = {-1/16, -.5+1/16, .5-1/16, 1/16, .4999+1/16, .5}, -- z positive up
	[6] = {-.5, -.5+1/16, -1/16, -.5+1/16, .4999+1/16, 1/16}, -- x negative up
	[7] = {-1/16, -.5+1/16, -.5, 1/16, .4999+1/16, -.5+1/16}  -- z negative up
}

local selectionbox =
{
	type = "fixed",
	fixed = {-.5, -.5, -.5, .5, -.5+4/16, .5}
}

-- go to the next nodeid (ex.: 01000011 --> 01000100)
local nid_inc = function() end
nid_inc = function(nid)
	local i = 0
	while nid[i-1] ~= 1 do
		nid[i] = (nid[i] ~= 1) and 1 or 0
		i = i + 1
	end

	-- BUT: Skip impossible nodeids, e.g. more than two connections
	if ((nid[0] == 0 and nid[4] == 1) or (nid[1] == 0 and nid[5] == 1)
	or (nid[2] == 0 and nid[6] == 1) or (nid[3] == 0 and nid[7] == 1)) then
		return nid_inc(nid)
	end
	if nid[0] + nid[1] + nid[2] + nid[3] > 2 then
		return nid_inc(nid)
	end

	return i <= 8
end

local function register_wires(name, technologyspec)
	local nid = {0, 0, 0, 0, 0, 0, 0, 0}
	while true do
		-- Create group specifiction and nodeid string (see note above for details)
		local nodeid = 	  (nid[0] or "0")..(nid[1] or "0")..(nid[2] or "0")..(nid[3] or "0")
				..(nid[4] or "0")..(nid[5] or "0")..(nid[6] or "0")..(nid[7] or "0")

		-- Calculate nodebox
		local nodebox = {type = "fixed", fixed={box_center}}
		for i=0,7 do
			if nid[i] == 1 then
				table.insert(nodebox.fixed, nbox_nid[i])
			end
		end

		-- If nothing to connect to, still make a nodebox of a straight wire
		if nodeid == "00000000" then
			nodebox.fixed = {-8/16, -.5, -1/16, 8/16, -.5+1/16, 1/16}
		end

		local rules = {}
		if (nid[0] == 1) then table.insert(rules, vector.new( 1,  0,  0)) end
		if (nid[1] == 1) then table.insert(rules, vector.new( 0,  0,  1)) end
		if (nid[2] == 1) then table.insert(rules, vector.new(-1,  0,  0)) end
		if (nid[3] == 1) then table.insert(rules, vector.new( 0,  0, -1)) end

		if (nid[0] == 1) then table.insert(rules, vector.new( 1, -1,  0)) end
		if (nid[1] == 1) then table.insert(rules, vector.new( 0, -1,  1)) end
		if (nid[2] == 1) then table.insert(rules, vector.new(-1, -1,  0)) end
		if (nid[3] == 1) then table.insert(rules, vector.new( 0, -1, -1)) end

		if (nid[4] == 1) then table.insert(rules, vector.new( 1,  1,  0)) end
		if (nid[5] == 1) then table.insert(rules, vector.new( 0,  1,  1)) end
		if (nid[6] == 1) then table.insert(rules, vector.new(-1,  1,  0)) end
		if (nid[7] == 1) then table.insert(rules, vector.new( 0,  1, -1)) end

		local groups = reseau.tablecopy(technologyspec.groups) or {dig_immediate = 3}
		if nodeid ~= "00000000" then
			groups["not_in_creative_inventory"] = 1
		end

		local spec = reseau.mergetable(technologyspec, {
			drawtype = "nodebox",
			paramtype = "light",
			is_ground_content = false,
			sunlight_propagates = true,
			selection_box = selectionbox,
			node_box = nodebox,
			walkable = false,
			drop = "reseau:"..name.."_wire_00000000",
			is_reseau_wire = true,
			on_rotate = false,
			reseau = {
				conductor = {
					basename = name,
					technology = technologyspec.technology,
					rules = rules
				}
			}
		})
		spec.groups = groups

		minetest.register_node(":reseau:"..name.."_wire_"..nodeid, spec)

		if (nid_inc(nid) == false) then return end
	end
end

local function with_overlay(base, color, overlay_name)
	return base .. "^(" .. overlay_name .. "^[multiply:" .. color .. ")"
end

local function make_wire_tiles(base, color)
	local top = with_overlay(base, color, "reseau_wire_overlay_top.png")
	local side = with_overlay(base, color, "reseau_wire_overlay_side.png")
	return { top, top, side, side, side, side }
end

local function make_wire_inv(base, color)
	return with_overlay(base, color, "reseau_wire_overlay_inv.png")
end

for _, team in ipairs(teams.get_all()) do
	register_wires("copper_" .. team.name, {
		description = "Copper Cable",
		technology = "copper",
		team_name = team.name,
		tiles = make_wire_tiles("reseau_copper_wire.png", team.color),
		inventory_image = make_wire_inv("reseau_copper_wire_inv.png", team.color),
		wield_image = make_wire_inv("reseau_copper_wire_inv.png", team.color),
		groups = { ["protection_" .. team.name] = 1 }
	})

	register_wires("fiber_" .. team.name, {
		description = "Fiber Cable",
		technology = "fiber",
		team_name = team.name,
		-- TODO: per-team image
		tiles = make_wire_tiles("reseau_fiber_wire.png", team.color),
		inventory_image = make_wire_inv("reseau_fiber_wire_inv.png", team.color),
		wield_image = make_wire_inv("reseau_fiber_wire_inv.png", team.color),
		groups = { ["protection_" .. team.name] = 1 }
	})
end
