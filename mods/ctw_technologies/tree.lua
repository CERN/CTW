-- Craft The Web
-- Technologies - form and algorithm for creating the tech tree

local technologies = ctw_technologies._get_technologies()

local colors = {
	"red",
	"green",
	"blue",
	"yellow",
	"brown",
	"white",
}


local function contains(tab, value)
	for _,v in ipairs(tab) do
		if v==value then return true end
	end
	return false
end

local function logs(str)
	minetest.log("action", "[ctw_technologies] "..str)
end

-- form renderer

local function rng(x, mi, ma)
	return math.max(math.min(x, ma), mi)
end
local function clipx(x, fdata)
	return rng(x-fdata.offx, fdata.minx, fdata.maxx)
end
local function clipy(y, fdata)
	return rng(y-fdata.offy, fdata.miny, fdata.maxy)
end

local function tech_entry(px, py, techid, disco, hithis, fdata)
		local x = px-fdata.offx
		local y = py-fdata.offy
		local fwim = 1
		local fwte = 2
		local fhim = 0.7
		local fhte = 2
		if (x+fwim+fwte)<fdata.minx or y<fdata.miny or x>fdata.maxx or (y+fhte)>fdata.maxy then
			return ""
		end

		local tech = ctw_technologies.get_technology(techid)
		local img = tech.image or "ctw_technologies_technology.png"
		
		local name
		if hithis then
			name = minetest.colorize("#FF0000", tech.name)
		elseif disco then
			name = minetest.colorize("#00FF00", tech.name)
		else
			name = tech.name
		end

		local form = "image_button["
						..(x)..","..(y)..";"..fwim..","..fhim..";"
						..img..";"
						.."goto_tech_"..techid..";"
						.."]"
		--form = form .. "textarea["
		--				..(x+fwim+0.1)..","..(y)..";"..fwte..","..fhte..";"
		--				..";;"..name.."]"
		form = form .. "label["
						..(x+fwim)..","..(y)..";"..name.."]"
		return form
	end

-- Renders the technology tree onto a given formspec area
-- wwidth:  formspec width
-- wheight: formspec height
function ctw_technologies.render_tech_tree(wwidth, wheight, discovered_techs, scrollpos, hilit)
	local drawio_position = ctw_technologies.tech_tree_positions

	scrollpos = rng(scrollpos, 0, 1000)
	local image_h = wheight - 1.5
	local origin = drawio_position.origin
	local bottom = drawio_position.bottom
	local img_dimensions = {
		x = bottom.x - origin.x,
		y = bottom.y - origin.y
	}
	local scale = image_h / img_dimensions.y
	local image_w = scale * img_dimensions.x
	local x_offset = scrollpos / 1000 * image_w

	local function calculate_pos(id, tech_def)
		local x_pos = tech_def.tree_x or drawio_position[tech_def.year]
			or drawio_position.earlier
		local y_pos = tech_def.tree_y or 0
		x_pos = (x_pos - origin.x) * scale - x_offset
		y_pos = (y_pos - origin.y) * scale
		print(dump(drawio_position))
		print(id, drawio_position[tech_def.year], tech_def.year, x_pos, y_pos)
		return x_pos, y_pos
	end

	local formt = {
		"formspec_version[2]",
		("size[%f,%f]"):format(wwidth, wheight),
		"no_prepend[]"
	}

	table.insert(formt, ("background[%f,0;%f,%f;ctw_tech_tree.png]"):format(
		-x_offset, image_w, image_h))

	-- Draw buttons
	for tech_id, def in pairs(ctw_technologies._get_technologies()) do
		if discovered_techs[tech_id] then
			local x, y = calculate_pos(tech_id, def)
			table.insert(formt, ("image_button[%f,%f;2.6,0.9;default_stone.png;%s;%s]"):format(
				x, y, "test", def.name))
		end
	end

	table.insert(formt, "button[0,"..(wheight-1.5)..";1,1;mleft;<<]")
	table.insert(formt, "button["..(wwidth-1)..","..(wheight-1.5)..";1,1;mright;>>]")
	table.insert(formt, "scrollbar[0,"..(wheight-0.5)..";"..wwidth..",0.5;horizontal;scrollbar;"..
			scrollpos.."]")
	return table.concat(formt, "\n")
end

function ctw_technologies.show_tech_tree(pname, scrollpos)
	local team = teams.get_by_player(pname)
	local dtech = {}
	if team then
		for techid,_ in pairs(ctw_technologies._get_technologies()) do
			if ctw_technologies.is_tech_gained(techid, team) then
				dtech[techid] = true
			end
		end
	end
	local form = ctw_technologies.render_tech_tree(20, 15, dtech, scrollpos, nil)
	minetest.show_formspec(pname, "ctw_technologies:tech_tree", form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	if formname == "ctw_technologies:tech_tree" then
		for techid, tech in pairs(technologies) do
			-- look if field was clicked
			if fields["goto_tech_"..techid] or fields["goto_techt_"..techid] then
				if ctw_technologies.get_technology_raw(techid) then
						ctw_technologies.show_technology_form(pname, techid)
					end
				return
			end
			if fields.mleft then
				local ev = minetest.explode_scrollbar_event(fields.scrollbar)
				if ev.type=="VAL" then
					ctw_technologies.show_tech_tree(pname, ev.value - 200, {}, nil)
				end
			end
			if fields.mright then
				local ev = minetest.explode_scrollbar_event(fields.scrollbar)
				if ev.type=="VAL" then
					ctw_technologies.show_tech_tree(pname, ev.value + 200, {}, nil)
				end
			end
			if not fields.quit and fields.scrollbar then
				local ev = minetest.explode_scrollbar_event(fields.scrollbar)
				if ev.type=="CHG" then
					ctw_technologies.show_tech_tree(pname, ev.value, {}, nil)
				end
			end
		end
	end

end)

minetest.register_chatcommand("ctwtr", {
         param = "",
         description = "tech tree",
         privs = {},
         func = function(pname, params)
				ctw_technologies.show_tech_tree(pname, tonumber(params) or 0)
        end,
})
