-- Craft The Web
-- Technologies - technology tree and information

ctw_technologies = {}

local mp = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM

dofile(mp.."technologies.lua")
dofile(mp.."tree.lua")

dofile(mp.."tech_defs.lua")

-- construct tree
ctw_technologies.build_tech_tree()


-- TODO only for testing

minetest.register_chatcommand("ctwt", {
         param = "tech",
         description = "Gain a technology",
         privs = {},
         func = function(pname, params)
				return ctw_technologies.gain_technology(params, teams.get_by_player(pname))
        end,
})
