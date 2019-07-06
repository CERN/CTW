homedecor = homedecor or {}

local placeholder_node = "homedecor:expansion_placeholder"

--wrapper around minetest.register_node that sets sane defaults and interprets some specialized settings
function homedecor.register(name, original_def)
	local def = table.copy(original_def)

	def.drawtype = def.drawtype
		or (def.mesh and "mesh")
		or (def.node_box and "nodebox")

	def.paramtype = def.paramtype or "light"

	-- avoid facedir for some drawtypes as they might be used internally for something else
	-- even if undocumented
	if not (def.drawtype == "glasslike_framed"
		or def.drawtype == "raillike"
		or def.drawtype == "plantlike"
		or def.drawtype == "firelike") then

		def.paramtype2 = def.paramtype2 or "facedir"
	end

	homedecor.handle_inventory(name, def, original_def)

	local infotext = def.infotext
	--def.infotext = nil -- currently used to set locked refrigerator infotexts

	if infotext then
		local on_construct = def.on_construct
		def.on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", infotext)
			if on_construct then on_construct(pos) end
		end
	end

	local expand  = def.expand
	def.expand = nil
	local after_unexpand = def.after_unexpand
	def.after_unexpand = nil

	if expand then
		-- dissallow rotating only half the expanded node by default
		-- unless we know better
		def.on_rotate = def.on_rotate
			or (def.mesh and expand.top and screwdriver.rotate_simple)
			or screwdriver.disallow

		def.on_place = def.on_place or function(itemstack, placer, pointed_thing)
			if expand.top then
				return homedecor.stack_vertically(itemstack, placer, pointed_thing, itemstack:get_name(), expand.top)
			elseif expand.right then
				return homedecor.stack_sideways(itemstack, placer, pointed_thing, itemstack:get_name(), expand.right, true)
			elseif expand.forward then
				return homedecor.stack_sideways(itemstack, placer, pointed_thing, itemstack:get_name(), expand.forward, false)
			end
		end
		def.after_dig_node = def.after_dig_node or function(pos, oldnode, oldmetadata, digger)
			if expand.top and expand.forward ~= "air" then
				local top_pos = { x=pos.x, y=pos.y+1, z=pos.z }
				local node = minetest.get_node(top_pos).name
				if node == expand.top or node == placeholder_node then
					minetest.remove_node(top_pos)
				end
			end

			local fdir = oldnode.param2
			if not fdir or fdir > 3 then return end

			if expand.right and expand.forward ~= "air" then
				local right_pos = { x=pos.x+homedecor.fdir_to_right[fdir+1][1], y=pos.y, z=pos.z+homedecor.fdir_to_right[fdir+1][2] }
				local node = minetest.get_node(right_pos).name
				if node == expand.right or node == placeholder_node then
					minetest.remove_node(right_pos)
				end
			end
			if expand.forward and expand.forward ~= "air" then
				local forward_pos = { x=pos.x+homedecor.fdir_to_fwd[fdir+1][1], y=pos.y, z=pos.z+homedecor.fdir_to_fwd[fdir+1][2] }
				local node = minetest.get_node(forward_pos).name
				if node == expand.forward or node == placeholder_node then
					minetest.remove_node(forward_pos)
				end
			end

			if after_unexpand then
				after_unexpand(pos)
			end
		end
	end

	-- register the actual minetest node
	minetest.register_node(":homedecor:" .. name, def)
end
