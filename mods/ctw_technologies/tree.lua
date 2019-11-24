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
		{ slvl,  Level(horizontal) where conn starts
		sline,   Line (vertical) where conn starts
		soff,    Vertical offset of line start
		elvl, 
		eline,   same for end
		eoff, 
		clvl,    level of vertical line
		color    line color
		}    
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

local function calc_offset(this, total)
	return this - (total/2) - 0.5
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
	local handled_techs = {}
	-- for every queue item, add its descendants and add current level
	while #c_queue > 0 do
		local techid = c_queue[1]
		table.remove(c_queue, 1)
		local tech = technologies[techid]
		
		local dep_is_at = {}
		for depno, atechid in ipairs(tech.requires) do
			local atech = technologies[atechid]
			if atech.tree_level >= tech.tree_level then
				error("technology '"..techid.."' depends on '"..techid
					.."' which is on same or later level, must rearrange!")
			end
			-- locate dependency line
			local soff = 0
			for sindex,stechid in ipairs(atech.enables) do
				if stechid == techid then
					soff = sindex
				end
			end
			
			dep_is_at[depno]={
				sline = atech.tree_line,
				slvl = atech.tree_level,
				soff = calc_offset(soff,#atech.enables)
			}
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
		for eindex, e in ipairs(dep_is_at) do
			logs("\tdep. conn to "..e.slvl..":"..e.sline)
			local dep_techid = tech.requires[eindex]
			local conn_info = {}
			if tech.conn_info and tech.conn_info[dep_techid] then
				conn_info = tech.conn_info[dep_techid]
			end
			local color = conn_info.color or colors[math.random(1,#colors)] -- select random color
			local conns_lvl = lvl - (conn_info.vertline_offset or 0)
			local conn = {
				sline=e.sline, 
				slvl=e.slvl,
				soff= conn_info.start_shift or e.soff,
				eline=my_line, 
				elvl=lvl,
				eoff= conn_info.end_shift or calc_offset(eindex,#dep_is_at),
				clvl=conns_lvl, 
				color=color
			}
			
			table.insert(render_info.conns, conn)
			logs("\t\tDrawing connection:"
				..conn.slvl..":"..conn.sline.."o"..conn.soff.." -| "
				..conn.clvl.." "..conn.color.." |- "
				..conn.elvl..":"..conn.eline.."o"..conn.eoff)
		end

		-- add enables to the queue
		for _, atechid in ipairs(tech.enables) do
			if not handled_techs[atechid] then
				logs("\tenables "..atechid)
				handled_techs[atechid] = true
				table.insert(c_queue, atechid)
			end
		end
	end
	logs("Building the technology tree done.")
	for techid, tech in pairs(technologies) do
		-- scan through technologies and find which techs have this as requirement
		if not tech.tree_level then
			minetest.log("warning", "[ctw_technologies] Technology "..techid
				.." is not included in the tree, is this a cycle?")
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

local function round3(x)
	return math.floor(1000*x)/1000
end

local line_width = 2*round3(0.025)
local function hline_as_box(psx, pex, py, fdata, color)
	psx, pex, py = round3(psx), round3(pex), round3(py)
	if psx>pex then
		psx, pex = pex, psx
	end
	local sx = clipx(psx-line_width/2, fdata)
	local ex = clipx(pex+line_width/2, fdata)
	local y = py-fdata.offy
	if y<=fdata.miny or y>=fdata.maxy or sx>=ex then
		return ""
	end
	return "box["..sx..","..(y-line_width/2)..";"..(ex-sx)..","..line_width..";"..color.."]"
end
local function vline_as_box(px, psy, pey, fdata, color)
	psy, pey, px = round3(psy), round3(pey), round3(px)
	if psy>pey then
		psy, pey = pey, psy
	end
	local sy = clipy(psy-line_width/2, fdata)
	local ey = clipy(pey+line_width/2, fdata)
	local x = px-fdata.offx
	if x<=fdata.minx or x>=fdata.maxx or sy>=ey then
		return ""
	end
	return "box["..(x-line_width/2)..","..sy..";"..line_width..","..(ey-sy)..";"..color.."]"
end

local function tech_entry(px, py, techid, disco, hithis, fdata)
		local x = px-fdata.offx
		local y = py-fdata.offy
		local fwim = 1
		local fwbo = 3.7
		local fwte = 3.0
		local fhim = 0.7
		local fhbo = 0.55
		local fhte = 2
		if (x+fwim+fwte)<fdata.minx or y<fdata.miny or x>fdata.maxx or (y+fhte)>fdata.maxy then
			return ""
		end

		local tech = ctw_technologies.get_technology(techid)
		--local img = tech.image or "ctw_technologies_technology.png"
		
		local name = tech.name
		local color = "blue"
		if hithis then
			color = "red"
		elseif disco then
			color = "green"
		end
		local img = "ctw_technologies_tech_button_" .. color .. ".png"

		--local form = "image_button["
		--				..(x)..","..(y)..";"..fwim..","..fhim..";"
		--				..img..";"
		--				.."goto_tech_"..techid..";"
		--				.."]"

		local box_x = x
		local box_width = fwbo
		if box_x < fdata.minx then
			box_width = box_width - (fdata.minx-box_x)
			box_x = fdata.minx
		end
		if box_x + box_width > fdata.maxx then
			box_width = fdata.maxx - box_x
		end
		
		local form = ""

		--form = form .. "box["
		--				..(box_x)..","..(y)..";"..box_width..","..fhbo..";"
		--				..color.."]"
		form = form .."image_button["
						..(x)..","..(y)..";"..fwbo..","..fhim..";"
						..img..";"
						.."goto_tech_"..techid..";"
						..name.."]"

		--form = form .. "textarea["
		--				..(x+fwim+0.1)..","..(y)..";"..fwte..","..fhte..";"
		--				..";;"..name.."]"
		
		--form = form .. "label["
		--				..(x+fwim)..","..(y)..";"..name.."]"
		return form
	end


-- Renders the technology tree onto a given formspec area
--
function ctw_technologies.render_tech_tree(minpx, minpy, wwidth, wheight, discovered_techs, scrollpos, hilit)
	local lvl_init_off  = -3.5
	local lvl_space     =  5.0
	local conn_init_off = -4.0
	local conn_space    =  0.1
	local conn_linestart=  3.7
	local line_init_off = -0.5
	local line_space    =  0.9
	local conn_ydown    =  0.2
	local conn_offset_factor = 0.1
	local scroll_w = (render_info.max_levels+1)*lvl_space

	scrollpos = rng(scrollpos, 0, 1000)

	local fdata = {
		minx = minpx,
		miny = minpy,
		maxx = minpx+wwidth,
		maxy = minpy+wheight,

		offx = round3(math.max( (scroll_w - wwidth) * (scrollpos / 1000) , 0)),
		offy = 0,
	}

	local formt = {}
	
	-- render years and eras
	for lvl, capt in ipairs(ctw_technologies.year_captions) do
		if capt~="" then
			table.insert(formt, "label["..(lvl*lvl_space + lvl_init_off - 0.2 - fdata.offx)..",10;|]")
			table.insert(formt, "label["..(lvl*lvl_space + lvl_init_off + 1   - fdata.offx)..",10;"..capt.."]")
		end
	end
	for _, era in ipairs(ctw_technologies.eras) do
		local lvl = (era.s+era.e)/2
		table.insert(formt, "label["..(era.s*lvl_space + lvl_init_off - 0.2 - fdata.offx)..",10.3;|]")
		table.insert(formt, "label["..(lvl  *lvl_space + lvl_init_off + 1   - fdata.offx)..",10.3;"..era.n.."]")
	end
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
		local startx = conn.slvl*lvl_space + lvl_init_off + conn_linestart + line_width/2
		local vlinex = conn.clvl*lvl_space + conn_init_off -- + xdisp*conn_space
		local endx = conn.elvl*lvl_space + lvl_init_off - line_width/2
		local starty = conn.sline*line_space + line_init_off + conn_ydown + conn.soff*conn_offset_factor
		local endy = conn.eline*line_space + line_init_off + conn_ydown + conn.eoff*conn_offset_factor
		table.insert(formt, hline_as_box(startx, vlinex, starty, fdata, color))
		table.insert(formt, vline_as_box(vlinex, starty, endy, fdata, color))
		table.insert(formt, hline_as_box(vlinex, endx, endy, fdata, color))
	end

	table.insert(formt, "button_exit["..(minpx+wwidth/2-1.5)..","..(minpy+wheight-1.5)..";4,1;quit;Close]")
	table.insert(formt, "button["..minpx..","..(minpy+wheight-1.5)..";1,1;mleft;<<]")
	table.insert(formt, "button["..(minpx+wwidth-1)..","..(minpy+wheight-1.5)..";1,1;mright;>>]")
	table.insert(formt, "scrollbar["..minpx..","..(minpy+wheight-0.5)..";"..wwidth..",0.5;horizontal;scrollbar;"..
			scrollpos.."]")
	return table.concat(formt, "\n")
end

local function get_dtech_for_player(pname)
	local team = teams.get_by_player(pname)
	local dtech = {}
	if team then
		for techid,_ in pairs(ctw_technologies._get_technologies()) do
			if ctw_technologies.is_tech_gained(techid, team) then
				dtech[techid] = true
			end
		end
	end
	return dtech
end

function ctw_technologies.show_tech_tree(pname, scrollpos)
	local form = "size[17,12]real_coordinates[true]"
			..ctw_technologies.render_tech_tree(0, 0, 17, 12, get_dtech_for_player(pname), scrollpos, nil)
	minetest.show_formspec(pname, "ctw_technologies:tech_tree", form)
end

local function handle_player_receive_fields(pname, fields, callback)
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
				callback(pname, ev.value - 1000*(3/(render_info.max_levels)))
			end
		end
		if fields.mright then
			local ev = minetest.explode_scrollbar_event(fields.scrollbar)
			if ev.type=="VAL" then
				callback(pname, ev.value + 1000*(3/(render_info.max_levels)))
			end
		end
		if not fields.quit and fields.scrollbar then
			local ev = minetest.explode_scrollbar_event(fields.scrollbar)
			if ev.type=="CHG" then
				callback(pname, ev.value)
			end
		end
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	if formname == "ctw_technologies:tech_tree" then
		handle_player_receive_fields(pname, fields, ctw_technologies.show_tech_tree)
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

function sfinv.get_homepage_name(player)
	return "ctw_technologies:tree"
end

sfinv.register_page("ctw_technologies:tree", {
	title = "Tech tree",
	get = function(self, player, context)
		local dtech = get_dtech_for_player(player:get_player_name())
		local content = ctw_technologies.render_tech_tree(0, 0, 17, 12, dtech, context.ctw_technologies_tree_scroll or 0, nil)
		return sfinv.make_formspec(player, context, content, false, "size[17,12]real_coordinates[true]")
	end,
	on_player_receive_fields = function(self, player, context, fields)
		handle_player_receive_fields(player:get_player_name(), fields, function(pname, scrollbar)
			context.ctw_technologies_tree_scroll = scrollbar
			sfinv.set_player_inventory_formspec(player)
		end)
	end,
})

teams.register_on_team_changed(function(player, team_def)
	sfinv.set_player_inventory_formspec(player)
end)

ctw_technologies.register_on_gain(function(tech_def, team)
	for _, player in ipairs(teams.get_online_members(team)) do
		sfinv.set_player_inventory_formspec(player)
	end
end)
