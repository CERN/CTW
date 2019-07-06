-- Craft The Web
-- ctw-resources: Resources used to invent technologies
-- - Ideas
-- - References
-- - Permission


ctw_resources = {}

local mp = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM

dofile(mp.."ideas.lua")
dofile(mp.."references.lua")

dofile(mp.."idea_defs.lua")
