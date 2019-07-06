-- Craft The Web
-- ctw-resources: Resources used to invent technologies
-- - Ideas
-- - References
-- - Permission

--Advtrains dump (special treatment of pos and sigd)
function atdump(t, intend)
	local str
	if type(t)=="table" then
		if t.x and t.y and t.z then
			str=minetest.pos_to_string(t)
		else
			str="{"
			local intd = (intend or "") .. "  "
			for k,v in pairs(t) do
				if type(k)~="string" or not string.match(k, "^path[_]?") then
					-- do not print anything path-related
					str = str .. "\n" .. intd .. atdump(k, intd) .. " = " ..atdump(v, intd)
				end
			end
			str = str .. "\n" .. (intend or "") .. "}"
		end
	elseif type(t)=="boolean" then
		if t then
			str="true"
		else
			str="false"
		end
	elseif type(t)=="function" then
		str="<function>"
	elseif type(t)=="userdata" then
		str="<userdata>"
	else
		str=""..t
	end
	return str
end

function advtrains_print_concat_table(a)
	local str=""
	local stra=""
	local t
	for i=1,20 do
		t=a[i]
		if t==nil then
			stra=stra.."nil "
		else
			str=str..stra
			stra=""
			str=str..atdump(t).." "
		end
	end
	return str
end

atdebug=function(t, ...)
	local text=advtrains_print_concat_table({t, ...})
	minetest.log("action", "[ctw]"..text)
	minetest.chat_send_all("[ctw]"..text)
end


ctw_resources = {}

local mp = minetest.get_modpath(minetest.get_current_modname()) .. DIR_DELIM

dofile(mp.."ideas.lua")
dofile(mp.."references.lua")

dofile(mp.."idea_defs.lua")
