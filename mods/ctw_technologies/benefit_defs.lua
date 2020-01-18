--Craft The Web

local tpl = ctw_technologies.benefit_templates

ctw_technologies.register_benefit_type("wire_throughput_multiplier",
	tpl.multiply("ctw_texture_missing.png", "Transmission Line Throughput"))
ctw_technologies.register_benefit_type("receiver_throughput_multiplier",
	tpl.multiply("ctw_texture_missing.png", "Receiver Throughput"))
ctw_technologies.register_benefit_type("experiment_throughput_multiplier",
	tpl.multiply("ctw_texture_missing.png", "Experiment Throughput"))
ctw_technologies.register_benefit_type("router_throughput_multiplier",
	tpl.multiply("ctw_texture_missing.png", "Router Throughput"))

-- {type="supply", item="reseau:copper_cable"}
ctw_technologies.register_benefit_type("supply", {
	accumulator = function(list)
		local item_list = {}
		for _, b in ipairs(list) do
			table.insert(item_list, b.item)
		end
	end,
	renderer = function(bene)
		local image = "ctw_texture_missing.png"
		local istack = ItemStack(bene.item)
		local desc = istack:get_name()
		local idef = minetest.registered_items[istack:get_name()]
		if idef and idef.inventory_image then
			image = idef.inventory_image
			desc = idef.description
		end
		if istack:get_count() > 0 then
			return image, desc.." x"..istack:get_count()
		end

		return image, desc
	end,
	validate = function(self, bene)
		if not bene.item then
			minetest.log("error",  ("Benefit %s needs an item field "):format(self.name))
		end

		local stack = ItemStack(bene.item)
		for tname, _ in pairs(teams.get_dict()) do
			local name = stack:get_name():gsub("%%t", tname)
			if not minetest.registered_items[stack:get_name()] then
				minetest.log("error", ("Benefit %s references non-existant item: %s"):format(self.name, name))
				return
			end
		end
	end,
})

ctw_technologies.register_benefit_type("victory", tpl.bool("ctw_texture_missing.png", "Victory"))
