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
         param = "",
         description = "Reveal the hidden entry of the doc_example mod",
         privs = {},
         func = function(playername, params)
				doc.mark_entry_as_revealed("singleplayer", "ctw_technologies", params)
                doc.show_category("singleplayer", "ctw_technologies")
        end,
})
