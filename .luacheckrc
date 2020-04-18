unused_args = false
allow_defined_top = true

globals = {
	"teams",
	"ctw_resources",
	"sfinv",
	minetest = { fields = { "format_chat_message" } },
}

read_globals = {
	"DIR_DELIM",
	"core",
	"dump",
	"VoxelManip", "VoxelArea",
	"PseudoRandom", "ItemStack",
	"SecureRandom",
	table = { fields = { "copy" } },
	"unpack",
	"AreaStore",
	"minetest",
	"vector",
	"ChatCmdBuilder",
	"hudkit",
	"player_api",
	"doc",
	"worldedit",
	"Settings",
	"default",
}

exclude_files = {
	"mods/mtg",
	"mods/libs",
	"mods/homedecor",
	"mods/bakedclay",
}
