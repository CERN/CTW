-- Craft The Web
-- ctw-resources: Resources used to invent technologies
-- - Ideas
-- - References
-- - Permission


ctw_resources = {}
ctw_resources.LAST_ACTION_COOLDOWN = 60 -- 1 minute

local mp = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM

dofile(mp.."ideas.lua")
dofile(mp.."references.lua")
dofile(mp.."permission.lua")
dofile(mp.."inventing.lua")

dofile(mp.."idea_defs.lua")

minetest.register_chatcommand("ctwi", {
         param = "idea",
         description = "Get an idea",
         privs = {},
         func = function(pname, params)
			local player = minetest.get_player_by_name(pname)
			return ctw_resources.give_idea(params, pname, player:get_inventory(), "main")
        end,
})

minetest.register_chatcommand("ctwa", {
         param = "idea",
         description = "Get an approval",
         privs = {},
         func = function(pname, params)
			local player = minetest.get_player_by_name(pname)
			return ctw_resources.approve_idea(params, pname, player:get_inventory(), "main")
        end,
})
