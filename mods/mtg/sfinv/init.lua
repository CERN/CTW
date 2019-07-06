dofile(minetest.get_modpath("sfinv") .. "/api.lua")

sfinv.register_page("sfinv:crafting", {
	title = "Crafting",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, [[
				label[1.5,0.1;There is no crafting!];
		]], true, "size[5,0.4]")
	end
})
