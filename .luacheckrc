unused_args = false
allow_defined_top = true

globals = {
	"teams",
	"ChatCmdBuilder",
	"hudkit",
	"player_api",
	"doc",
	"worldedit",
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
	"vector"
}

exclude_files = {
	"mods/mtg",
	"mods/libs",
}
