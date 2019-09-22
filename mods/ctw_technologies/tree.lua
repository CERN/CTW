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

--[[
render_info = {
	levels = {
		<lvl> = {
			techid,
		},
	}
	conns = {
		{ slvl, sline, elvl, eline, clvl}
	}
	max_levels = <maximum number of levels>
}

]]--
local render_info = {}

local function contains(tab, value)
	for _,v in ipairs(tab) do
		if v==value then return true end
	end
	return false
end

local function logs(str)
	minetest.log("action", "[ctw_technologies] "..str)
end

function ctw_technologies.build_tech_tree()
	logs("Tree levels -> years:")
	local i=0
	while ctw_technologies.year_captions[i] do
		logs(i.."\t-> '"..ctw_technologies.year_captions[i].."'")
		i=i+1
	end
	
	
	logs("Building the technology tree...")
	for techid, tech in pairs(technologies) do
		-- scan through technologies and find which techs have this as requirement
		for atechid, atech in pairs(technologies) do
			if contains(atech.requires, techid) then
				table.insert(tech.enables, atechid)
			end
		end
	end
	render_info.max_levels = #ctw_technologies.year_captions
	render_info.levels = {}
	render_info.conns = {}
	
	-- Find dependencies between technologies and add connections
	local c_queue = {}
	-- find roots
	for techid, tech in pairs(technologies) do
		-- scan through technologies and find which techs have this as requirement
		if #tech.requires == 0 then
			table.insert(c_queue, techid)
		end
	end
	-- for every queue item, add its descendants and add current level
	while #c_queue > 0 do
		local techid = c_queue[1]
		table.remove(c_queue, 1)
		local tech = technologies[techid]
		
		local dep_is_at = {}
		for depno, atechid in ipairs(tech.requires) do
			local atech = technologies[atechid]
			if atech.tree_level >= tech.tree_level then
				error("technology '"..techid.."' depends on '"..techid.."' which is on same or later level, must rearrange!")
			end
			-- locate dependency line
			dep_is_at[depno]={sline = atech.tree_line, slvl = atech.tree_level}
		end

		local lvl = tech.tree_level
		-- add render info
		render_info.max_levels = math.max(lvl, render_info.max_levels)
		if not render_info.levels[lvl] then
			render_info.levels[lvl] = {}
		end
		local my_line = tech.tree_line or (#render_info.levels[lvl] + 1)
		logs(techid.." at "..lvl..":"..my_line)
		render_info.levels[lvl][my_line] = techid
		tech.tree_line = my_line

		-- add connections
		local conns_lvl = tech.tree_conn_loc or (lvl-1)
		for _, e in ipairs(dep_is_at) do
			logs("\tdep. conn to "..e.slvl..":"..e.sline)
			local color = colors[math.random(1,#colors)] -- select random color
			table.insert(render_info.conns, {sline=e.sline, slvl=e.slvl, eline=my_line, elvl=lvl, clvl=conns_lvl, color=color})
		end

		-- add enables to the queue
		for _, atechid in ipairs(tech.enables) do
			if not contains(c_queue, atechid) then
				logs("\tenables "..atechid)
				table.insert(c_queue, atechid)
			end
		end
	end
	logs("Building the technology tree done.")
	for techid, tech in pairs(technologies) do
		-- scan through technologies and find which techs have this as requirement
		if not tech.tree_level then
			minetest.log("warning", "[ctw_technologies] Technology "..techid.." is not included in the tree, is this a cycle?")
		end
	end
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

local function hline_as_box(psx, pex, py, fdata, color)
	local sx = clipx(psx, fdata)
	local ex = clipx(pex, fdata)
	if sx>ex then
		sx, ex = ex, sx
	end
	local y = py-fdata.offy
	if y<=fdata.miny or y>=fdata.maxy or sx==ex then
		return ""
	end
	return "box["..sx..","..y..";"..(ex-sx+0.05)..",0.05;"..color.."]"
end
local function vline_as_box(px, psy, pey, fdata, color)
	local sy = clipy(psy, fdata)
	local ey = clipy(pey, fdata)
	if sy>ey then
		sy, ey = ey, sy
	end
	local x = px-fdata.offx
	if x<=fdata.minx or x>=fdata.maxx or sy==ey then
		return ""
	end
	return "box["..x..","..sy..";0.05,"..(ey-sy+0.05)..";"..color.."]"
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
--
function ctw_technologies.render_tech_tree(minpx, minpy, wwidth, wheight, discovered_techs, scrollpos, hilit)

	local lvl_init_off  = -3.5
	local lvl_space     =  5.0
	local conn_init_off = -0.1
	local conn_space    =  0.1
	local line_init_off = -0.5
	local line_space    =  0.9
	local conn_ydown    =  0.2
	local scroll_w = (render_info.max_levels+1)*lvl_space

	scrollpos = rng(scrollpos, 0, 1000)

	local fdata = {
		minx = minpx,
		miny = minpy,
		maxx = minpx+wwidth,
		maxy = minpy+wheight,

		offx = math.max( (scroll_w - wwidth) * (scrollpos / 1000) , 0),
		offy = 0,
	}

	local formt = {}

	-- render technology elements
	for lvl, lines in pairs(render_info.levels) do
		for line, techid in pairs(lines) do
			local hithis = (hilit == techid)
			table.insert(formt, tech_entry(lvl*lvl_space + lvl_init_off, line*line_space + line_init_off,
					techid, discovered_techs[techid], hithis, fdata))
		end
	end

	-- render conns
	for _, conn in pairs(render_info.conns) do
		local color = conn.color
		local vlinep = conn.clvl*lvl_space + conn_init_off -- + xdisp*conn_space
		table.insert(formt, hline_as_box(conn.slvl*lvl_space + lvl_init_off + 2.5, vlinep,
				conn.sline*line_space + line_init_off + conn_ydown, fdata, color))
		table.insert(formt, vline_as_box(vlinep, conn.sline*line_space + line_init_off + conn_ydown,
				conn.eline*line_space + line_init_off + conn_ydown, fdata, color))
		table.insert(formt, hline_as_box(vlinep, conn.elvl*lvl_space + lvl_init_off,
				conn.eline*line_space + line_init_off + conn_ydown, fdata, color))
	end
	table.insert(formt, "button["..minpx..","..(minpy+wheight-1.5)..";1,1;mleft;<<]")
	table.insert(formt, "button["..(minpx+wwidth-1)..","..(minpy+wheight-1.5)..";1,1;mright;>>]")
	table.insert(formt, "scrollbar["..minpx..","..(minpy+wheight-0.5)..";"..wwidth..",0.5;horizontal;scrollbar;"..
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
	local form = "size[17,12]"
			..ctw_technologies.render_tech_tree(0, 0, 17, 12, dtech, scrollpos, nil)
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
					ctw_technologies.show_tech_tree(pname, ev.value - 1000*(3/(render_info.max_levels)), {}, nil)
				end
			end
			if fields.mright then
				local ev = minetest.explode_scrollbar_event(fields.scrollbar)
				if ev.type=="VAL" then
					ctw_technologies.show_tech_tree(pname, ev.value + 1000*(3/(render_info.max_levels)), {}, nil)
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
