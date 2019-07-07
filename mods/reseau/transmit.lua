-- transmit to the first connection that is found
reseau.transmit_first = function(txpos, message)
	return reseau.transmit(txpos, txpos, message)
end

-- Warning: Connecting RX and TX directly will not check technology compatibility
-- Returns packet throughput that was actually achieved until next node (e.g. receiver / router)
reseau.transmit = function(previous, frontier, packet, startdepth)
	local depth = startdepth or 0

	while true do
		-- find next node (link)
		local links = reseau.get_all_links(frontier)
		if #links == 0 then break end
		local link = not vector.equals(links[1], previous) and links[1] or links[2]
		if link == nil then break end
		reseau.load_position(link)

		-- switch to next node
		previous = frontier
		frontier = nil
		depth = depth + 1

		-- process next node: technology's throughput?
		local technology = reseau.technologies.get_any_node_technology(minetest.get_node(link).name)
		packet.throughput = math.min(packet.throughput, reseau.throughput.get_wire_throughput(technology))

		-- process next node: conductor or receiver?
		local link_node_spec = minetest.registered_nodes[minetest.get_node(link).name]
		if link_node_spec.reseau.conductor then
			frontier = link
			reseau.bitparticles_conductor(link, depth)
		elseif link_node_spec.reseau.receiver then
			local throughput_limit = link_node_spec.reseau.receiver.action(link, packet, depth)
			packet.throughput = throughput_limit < packet.throughput and throughput_limit or packet.throughput
			return packet.throughput
		end
	end

	return 0
end
