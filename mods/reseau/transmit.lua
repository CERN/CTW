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
