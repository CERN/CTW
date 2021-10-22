-- Default

local stonegroups = {
	"default:sandstone",
	"default:sandstonebrick",
	"default:sandstone_block",
	"default:desert_sandstone_brick",
	"default:silver_sandstone",
	"default:silver_sandstone_brick",
	"default:silver_sandstone_block",
}

for _, name in ipairs(stonegroups) do
	local groups = minetest.registered_nodes[name].groups
	groups.stone = 1
	minetest.override_item(name, {
		groups = groups
	})
end

minetest.override_item("default:meselamp", {
	drawtype = "normal"
})
