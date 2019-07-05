reseau = {}
reseau.rules = {}
reseau.rules.default = {
	{x =  0, y =  0, z = -1},
	{x =  1, y =  0, z =  0},
	{x = -1, y =  0, z =  0},
	{x =  0, y =  0, z =  1},
	{x =  1, y =  1, z =  0},
	{x =  1, y = -1, z =  0},
	{x = -1, y =  1, z =  0},
	{x = -1, y = -1, z =  0},
	{x =  0, y =  1, z =  1},
	{x =  0, y = -1, z =  1},
	{x =  0, y =  1, z = -1},
	{x =  0, y = -1, z = -1},
}

reseau.tablecopy = function(table) -- deep table copy
	if type(table) ~= "table" then return table end -- no need to copy
	local newtable = {}

	for idx, item in pairs(table) do
		if type(item) == "table" then
			newtable[idx] = reseau.tablecopy(item)
		else
			newtable[idx] = item
		end
	end

	return newtable
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

reseau.get_any_rules = function(nodename)
	local node = minetest.registered_nodes[nodename]
	local rules = {}

	if node.reseau then
		if node.reseau.conductor then
			rules = reseau.mergetable(rules, node.reseau.conductor.rules)
		elseif node.reseau.transmitter then
			rules = reseau.mergetable(rules, node.reseau.transmitter.rules)
		elseif node.reseau.receiver then
			rules = reseau.mergetable(rules, node.reseau.receiver.rules)
		end
	end

	return rules
end

reseau.get_any_technology = function(nodename)
	local nodespec = minetest.registered_nodes[nodename]
	local technology = nil

	if nodespec.reseau then
		if nodespec.reseau.conductor then
			technology = nodespec.reseau.conductor.technology
		elseif nodespec.reseau.receiver then
			technology = nodespec.reseau.receiver.technology
		elseif nodespec.reseau.transmitter then
			technology = nodespec.reseau.transmitter.technology
		end
	end

	return technology
end

reseau.technologies_compatible = function(nodename1, nodename2)
	local technology1 = reseau.get_any_technology(nodename1)
	local technology2 = reseau.get_any_technology(nodename2)

	if type(technology1) == "string" and type(technology2) == "string" then
		return technology1 == technology2
	elseif type(technology1) == "table" and type(technology2) == "string" then
		return reseau.table_contains(technology1, technology2)
	elseif type(technology1) == "string" and type(technology2) == "table" then
		return reseau.table_contains(technology2, technology1)
	elseif type(technology1) == "table" and type(technology2) == "table" then
		return #reseau.table_intersection(technology1, technology2) > 0
	end
end

dofile(minetest.get_modpath("reseau").."/wires.lua")

minetest.register_node(":reseau:testtransmitter", {
	description = "Transmitter (Testing)",
	tiles = {"default_tree.png"},
	groups = {cracky = 3},
	reseau = {
		transmitter = {
			technology = {
				"copper", "fiber"
			},
			rules = reseau.rules.default
		}
	},
})

local receiveCount = 0
local receiveCountHud = nil
minetest.register_node(":reseau:testreceiver", {
	description = "Receiver (Testing)",
	tiles = {"default_water.png"},
	groups = {cracky = 3},
	reseau = {
		receiver = {
			technology = {
				"copper", "fiber"
			},
			rules = reseau.rules.default,
			receive = function(pos, content)
				print("RECEIVED: "..dump(content))
				receiveCount = receiveCount + 1
				local player = minetest.get_player_by_name("singleplayer")
				local hudtext = "Received: " .. receiveCount

				if receiveCountHud ~= nil then
					player:hud_change(idx, "text", hudtext)
				else
					receiveCountHud = player:hud_add({
						hud_elem_type = "text",
						position = {x = 1.0, y = 0.0},
						offset = {x = -100, y = 20},
						text = hudtext,
						alignment = {x = 0, y = 0},
						scale = {x = 100, y = 100}
					})
				end
			end
		}
	},
})

minetest.register_abm({
	label = "transmitter tx",
	nodenames = {"reseau:testtransmitter"},
	interval = 3,
	chance = 1,
	action = function(pos)
		reseau.transmit(pos, "hello world!")
	end,
})

reseau.rules_link_oneway = function(startpos, startrules, destinationpos)
	for _, rule in ipairs(startrules) do
		if vector.equals(vector.add(startpos, rule), destinationpos) then
			return true
		end
	end

	return false
end

reseau.get_all_links = function(startpos)
	local links = {}

	local startnode = minetest.get_node(startpos)
	local startrules = reseau.get_any_rules(startnode.name)
	for _, rule in ipairs(startrules) do
		local target_pos = vector.add(startpos, rule)
		local target_nodename = minetest.get_node(target_pos).name
		local target_nodespec = minetest.registered_nodes[target_nodename]
		if target_nodespec.reseau and (target_nodespec.reseau.conductor or target_nodespec.reseau.receiver) then
			local target_rules = reseau.get_any_rules(target_nodename)
			if reseau.rules_link_oneway(target_pos, target_rules, startpos) then
				table.insert(links, target_pos)
			end
		end
	end

	return links
end

local BITPARTICLES_DELAY = 0.03
reseau.bitparticles_conductor = function(pos, depth)
	local minpos = vector.add(pos, vector.new(-0.5, -0.3, -0.5))
	local maxpos = vector.add(pos, vector.new( 0.5,  0.2,  0.5))

	local psspec = {
		amount = 3,
		time = 0.3,
		minpos = minpos,
		maxpos = maxpos,
		minvel = vector.new(-0.1, 0.2, -0.1),
		maxvel = vector.new( 0.1, 0.5,  0.1),
		minexptime = 0.1,
		maxexptime = 0.4,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = true,
		collision_removal = false,
		object_collision = false,
		vertical = false,
		texture = "reseau_zero.png",
		glow = 7
	}

	if math.random(1, 2) == 2 then
		psspec.texture = "reseau_one.png"
	end

	minetest.after((depth - 1) * BITPARTICLES_DELAY, function()
		minetest.add_particlespawner(psspec)
	end)
end

reseau.bitparticles_receiver = function(pos, depth)
	local minpos = vector.add(pos, vector.new(-0.2, -0.3, -0.2))
	local maxpos = vector.add(pos, vector.new( 0.2,  0.2,  0.2))

	local psspec = {
		amount = 20,
		time = 0.3,
		minpos = minpos,
		maxpos = maxpos,
		minvel = vector.new(-1.0, 5.5, -1.0),
		maxvel = vector.new( 1.0, 8.5, 1.0),
		minacc = vector.new(0, -10, 0),
		maxacc = vector.new(0, -10, 0),
		minexptime = 0.1,
		maxexptime = 2.5,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = false,
		collision_removal = false,
		object_collision = false,
		vertical = false,
		texture = "reseau_zero.png",
		glow = 7
	}

	minetest.after((depth - 1) * BITPARTICLES_DELAY, function()
		minetest.add_particlespawner(psspec)
		psspec.texture = "reseau_one.png"
		minetest.add_particlespawner(psspec)
	end)
end

-- Warning: Connecting RX and TX directly will not check technology compatibility
reseau.transmit = function(txpos, message)
	local frontier = txpos
	local previous = txpos
	local depth = 0

	while true do
		-- find next node (link)
		local links = reseau.get_all_links(frontier)
		if #links == 0 then break end
		local link = not vector.equals(links[1], previous) and links[1] or links[2]
		if link == nil then break end

		-- switch to next node
		previous = frontier
		frontier = nil
		depth = depth + 1

		-- process next node: conductor or receiver?
		local link_node_spec = minetest.registered_nodes[minetest.get_node(link).name]
		if link_node_spec.reseau.conductor then
			frontier = link
			reseau.bitparticles_conductor(link, depth)
		elseif link_node_spec.reseau.receiver then
			link_node_spec.reseau.receiver.receive(link, message)
			reseau.bitparticles_receiver(link, depth)
			break
		end
	end
end
