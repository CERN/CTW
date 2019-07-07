-- Craft The Web

--[[
A benefit is something you gain from a technology.
Benefits are of certain types. Each type is registered here.
Whenever technology changes, the benefits of a team are updated.

Benefits are accumulated over all available technology. The function for
this is provided in the registration. What the output of an accumulation is
is left up to the type registration. The accumulator must be commutative.

A benefit must be able to provide an image and a label to use in the
information formspec of technologies.

bene = {
	type = <type>,
	... arbitrary data ...
}

]]

benefit_types = {}
team_benefits_acc = {}

-- Registers a benefit type
--[[
 def = {
	accumulator = func(list)
	-- Must take: list - List of all benefit tables of this type (might be empty)
	-- Must return: the accumulated value (can be any type)
	renderer = func(bene)
	-- Must take: bene - a single benefit table
	-- Must return: image, label - texture and label to use in the form
}
]]--
function ctw_technologies.register_benefit_type(typename, def)
	benefit_types[typename] = def
end

function ctw_technologies.get_team_benefit(team, type, explicit_update)
	if not team_benefits_acc[team.name] or explicit_update then
		ctw_technologies.update_team_benefits(team)
	end
	return team_benefits_acc[team.name][type]
end

function ctw_technologies.update_team_benefits(team)
	local by_type = {}
	for tech_id, tech in pairs(ctw_technologies._get_technologies()) do
		if ctw_technologies.is_tech_gained(tech_id, team) then
			for _, bene in ipairs(tech.benefits) do
				local t = bene.type or ""
				if not by_type[t] then
					by_type[t] = {}
				end
				table.insert(by_type[t], bene)
			end
		end
	end
	local tb = {}
	for t,_ in benefit_types do
		tb[t] = ctw_technologies.accumulate_benefits(t, by_type[t] or {})
	end
	team_benefits_acc[team.name] = tb
end


function ctw_technologies.render_benefit(bene)
	local t = bene.type
	if not t or not benefit_types[t] then
		return "ctw_texture_missing.png","<unknown>"
	end
	return benefit_types[t].renderer(bene)
end

function ctw_technologies.accumulate_benefits(t, benelist)
	if not t or not benefit_types[t] then
		return nil
	end
	return benefit_types[t].accumulator(bene)
end


-- Templates

local tpl = {
	-- Simply multiplies the benefit values which are stored in a field called "value"
	-- bene = {type = "???", value = 1.5}
	multiply = function(image, label)
		return {
			accumulator = function(list)
				local a=1
				for _, b in ipairs(list) do a = a * b.value end
			end,
			renderer = function(bene)
				return image, label.." x"..bene.value
			end
		}
	end,
	-- Sums values of "value" up
	-- bene = {type = "???", f = 5}
	sum = function(image, label)
		return {
			accumulator = function(list)
				local a=0
				for _, b in ipairs(list) do a = a + b.value end
			end,
			renderer = function(bene)
				return image, label.." +"..bene.value
			end
		}
	end,
	-- Simple bool whether any of those benefits is present
	bool = function(image, label)
		return {
			accumulator = function(list)
				return #list > 0
			end,
			renderer = function(bene)
				return image, label
			end
		}
	end,
}

ctw_technologies.benefit_templates = tpl
