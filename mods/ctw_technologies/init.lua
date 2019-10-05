-- Craft The Web
-- Technologies - technology tree and information

ctw_technologies = {}

local mp = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM

dofile(mp.."technologies.lua")
dofile(mp.."benefits.lua")
dofile(mp.."tree.lua")
dofile(mp.."detail_form.lua")
dofile(mp.."benefit_defs.lua")
dofile(mp.."tech_defs.lua")
dofile(mp.."delivery.lua")


-- gain initial technologies
for team_id, team in pairs(teams.get_all()) do
	for tech_id, tech in pairs(ctw_technologies._get_technologies()) do
		if tech.year < 1980 then
			ctw_technologies.gain_technology(tech_id, team)
		end
	end
end

-- TODO only for testing

minetest.register_chatcommand("ctwt", {
         param = "tech",
         description = "Gain a technology",
         privs = {},
         func = function(pname, params)
				return ctw_technologies.gain_technology(params, teams.get_by_player(pname))
        end,
})
