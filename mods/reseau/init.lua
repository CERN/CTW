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

dofile(minetest.get_modpath("reseau").."/wires.lua")

minetest.register_node(":reseau:testtransmitter", {
	description = "Transmitter (Testing)",
	tiles = {"default_tree.png"},
	groups = {cracky = 3},
	reseau = {
		transmitter = {
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

reseau.bitparticles = function(pos)
	local minpos = vector.add(pos, vector.new(-0.5, -0.3, -0.5))
	local maxpos = vector.add(pos, vector.new( 0.5,  0.2,  0.5))

	local psspec = {
		amount = 2,
		time = 3,
		minpos = minpos,
		maxpos = maxpos,
		minvel = vector.new(-0.1, 0.2, -0.1),
		maxvel = vector.new( 0.1, 0.5,  0.1),
		minexptime = 0.2,
		maxexptime = 1,
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
	minetest.add_particlespawner(psspec)
end

reseau.transmit = function(txpos, message)
	local frontier = txpos
	local previous = txpos

	while frontier ~= nil do
		reseau.bitparticles(frontier)

		-- find next node (link)
		local links = reseau.get_all_links(frontier)
		local link = not vector.equals(links[1], previous) and links[1] or links[2]

		-- switch to next node
		previous = frontier
		frontier = nil

		-- process next node: conductor or receiver?
		if link ~= nil then
			local link_node_spec = minetest.registered_nodes[minetest.get_node(link).name]
			if link_node_spec.reseau.conductor then
				frontier = link
			elseif link_node_spec.reseau.receiver then
				link_node_spec.reseau.receiver.receive(link, message)
			end
		end
	end
end
