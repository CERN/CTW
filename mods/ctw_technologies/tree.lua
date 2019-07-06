-- Craft The Web
-- Technologies - form and algorithm for creating the tech tree

local technologies = ctw_technologies._get_technologies()

--[[
render_info = {
	levels = {
		<lvl> = {
			techid,
		},
	}
	conns = {
		<after_lvl> = {
			{ slvl, sline, elvl, eline}
		},
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
	logs("Building the technology tree...")
	for techid, tech in pairs(technologies) do
		-- remove level if it existed before
		tech.tree_level = nil
		-- scan through technologies and find which techs have this as requirement
		for atechid, atech in pairs(technologies) do
			if contains(atech.requires, techid) then
				table.insert(tech.enables, atechid)
			end
		end
	end
	render_info.max_levels = 0
	render_info.levels = {}
	render_info.conns = {}
	-- find parallel topological sorting of tree elements
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
		if tech.tree_level then
			error("Topological sorting tech tree failed at "..techid.." because it has already been placed in the tree! Check for cycles!")
		end
		-- get level as max of levels of nodes before
		local lvl = tech.min_tree_level or 0
		local dep_is_at = {}
		for depno, atechid in ipairs(tech.requires) do
			local atech = technologies[atechid]
			if not atech.tree_level then
				error("Topological sorting tech tree failed at "..techid.." because dependency "..atechid.." has no tree_level set!")
			end
			lvl = math.max(lvl, atech.tree_level + 1)
			
			-- locate dependency line
			dep_is_at[depno]={sline = atech.tree_line, slvl = atech.tree_level}
		end
		logs("Tech Tree Sort: "..techid.." on level "..lvl)
		tech.tree_level = lvl
		
		-- add render info
		render_info.max_levels = math.max(lvl, render_info.max_levels)
		if not render_info.levels[lvl] then
			render_info.levels[lvl] = {}
		end
		local my_line = tech.tree_line or (#render_info.levels[lvl] + 1)
		render_info.levels[lvl][my_line] = techid
		tech.tree_line = my_line
		
		-- add connections
		local conns_lvl = tech.tree_conn_loc or (lvl-1)
		if not render_info.conns[conns_lvl] then
			render_info.conns[conns_lvl] = {}
		end
		for _, e in ipairs(dep_is_at) do
			table.insert(render_info.conns[conns_lvl], {sline=e.sline, slvl=e.slvl, eline=my_line, elvl=lvl})
		end
		
		-- add enables to the queue
		for _, atechid in ipairs(tech.enables) do
			if not contains(c_queue, atechid) then
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

local function hline_as_box(psx, pex, py, fdata)
	local sx = clipx(psx, fdata)
	local ex = clipx(pex, fdata)
	if sx>ex then
		sx, ex = ex, sx
	end
	local y = py-fdata.offy
	if y<=fdata.miny or y>=fdata.maxy or sx==ex then
		return ""
	end
	return "box["..sx..","..y..";"..(ex-sx+0.1)..",0.1;red]"
end
local function vline_as_box(px, psy, pey, fdata)
	local sy = clipx(psy, fdata)
	local ey = clipx(pey, fdata)
	if sy>ey then
		sy, ey = ey, sy
	end
	local x = px-fdata.offx
	if x<=fdata.minx or x>=fdata.maxx or sy==ey then
		return ""
	end
	return "box["..x..","..sy..";0.1,"..(ey-sy+0.1)..";red]"
end

local function tech_entry(px, py, techid, disco, hithis, fdata)
		local x = px-fdata.offx
		local y = py-fdata.offy
		local fwim = 1
		local fwte = 3
		local fh = 1
		if x<fdata.minx or y<fdata.miny or (x+fwim+fwte)>fdata.maxx or (y+fh)>fdata.maxy then
			return ""
		end
		
		local tech = ctw_technologies.get_technology(techid)
		local img = tech.image or "ctw_technologies_technology.png"
		
		local form = "image_button["
						..(x)..","..(y)..";"..fwim..","..fh..";"
						..img..";"
						.."goto_tech_"..techid..";"
						.."]"
		form = form .. "button["
						..(x+fwim)..","..(y)..";"..fwte..","..fh..";"
						.."goto_techt_"..techid..";"
						..tech.name.."]"
		return form
	end


-- Renders the technology tree onto a given formspec area
-- 
function ctw_technologies.render_tech_tree(minpx, minpy, wwidth, wheight, scrollpos, discovered_techs, hilit)

	atdebug(render_info)
	
	local lvl_init_off = 0.5
	local lvl_space = 6
	local conn_init_off = 5
	local conn_space    = 0.2
	local line_init_off = 0.5
	local line_space    = 2
	local conn_ydown    = 0.4
	local scroll_w = render_info.max_levels*lvl_space
	
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
			table.insert(formt, tech_entry(lvl*lvl_space + lvl_init_off, line*line_space + line_init_off, techid, discovered_techs[techid], hithis, fdata))
		end
	end
	
	-- render conns
	for lvl, conns in pairs(render_info.conns) do
		for xdisp,conn in pairs(conns) do
			local vlinep = lvl*lvl_space + conn_init_off + xdisp*conn_space
			table.insert(formt, hline_as_box(conn.slvl*lvl_space + lvl_init_off + 3.5, vlinep, conn.sline*line_space + line_init_off + conn_ydown, fdata))
			table.insert(formt, vline_as_box(vlinep, conn.sline*line_space + line_init_off + conn_ydown, conn.eline*line_space + line_init_off + conn_ydown, fdata))
			table.insert(formt, hline_as_box(vlinep, conn.elvl*lvl_space + lvl_init_off, conn.eline*line_space + line_init_off + conn_ydown, fdata))
		end
	end
	
	return table.concat(formt, "\n")
end

function ctw_technologies.show_tech_tree(pname, scrollpos)
	local form = "size[17,10]"..ctw_technologies.render_tech_tree(0, 0, 17, 10, 0, {}, nil)
	logs(form)
	minetest.show_formspec(pname, "ctw_tech_tree", form)
end

minetest.register_chatcommand("ctwtr", {
         param = "",
         description = "tech tree",
         privs = {},
         func = function(pname, params)
				ctw_technologies.show_tech_tree(pname, tonumber(params) or 0)
        end,
})

