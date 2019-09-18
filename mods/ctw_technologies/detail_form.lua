-- Common template for the technology/idea/resource information formspec.
-- Helps with links and backlinks
	
-- Formspec information
FORM = {}
-- Width of formspec
FORM.WIDTH = 15
FORM.HEIGHT = 10.5

--[[ Recommended bounding box coordinates for widgets to be placed in entry pages. Make sure
all entry widgets are completely inside these coordinates to avoid overlapping. ]]
FORM.ENTRY_START_X = 1
FORM.ENTRY_START_Y = 0.5
FORM.ENTRY_END_X = FORM.WIDTH
FORM.ENTRY_END_Y = FORM.HEIGHT - 0.5
FORM.ENTRY_WIDTH = FORM.ENTRY_END_X - FORM.ENTRY_START_X
FORM.ENTRY_HEIGHT = FORM.ENTRY_END_Y - FORM.ENTRY_START_Y
	
--[[ formdef = {
	bt1 = {
		catlabel = "Technologies required:",
		func = function(entry, idx)-> btnname,label,img
		entries
	},
	bt2 = ...,
	bt3 = ...,
	vert_text = "T E X T",
	title = "World Wide Web",
	text = "bla bla", --( if nil, uses a label with labeltext )
	labeltext = "Undiscovered Technology",
	
	add_btn_name = "my_button", -- optional, additional extra button
	add_btn_label = "My Extra Button",
	
} ]]--


function ctw_technologies.get_detail_formspec(formdef)
	local n_tech_lines = math.max(math.max(#formdef.bt1.entries, #formdef.bt2.entries), #formdef.bt3.entries)

	local tech_line_h = 1
	local desc_height = FORM.ENTRY_HEIGHT - tech_line_h*n_tech_lines - 0.5
	local tech_start_y = FORM.ENTRY_START_Y + desc_height
	local third_width = FORM.ENTRY_WIDTH / 3

	local form = "size["..FORM.WIDTH..","..FORM.HEIGHT.."]real_coordinates[]"
	
	form = form .. "vertlabel[0.15,0.5"
					..";"..formdef.vert_text.."]";
	form = form .. "box[0,0;0.5,"..FORM.HEIGHT..";#00FF00]";
	
	
	form = form .. "label["
					..FORM.ENTRY_START_X..","..FORM.ENTRY_START_Y
					..";"..formdef.title.."\n"..string.rep("=", #formdef.title).."]";
	
	if formdef.text then
		form = form .. doc.widgets.text(formdef.text, FORM.ENTRY_START_X, FORM.ENTRY_START_Y + 1,
				FORM.ENTRY_WIDTH - 0.4, desc_height-1)
	else
		form = form .. "label["
					..FORM.ENTRY_START_X..","..(FORM.ENTRY_START_Y+2)
					..";"..formdef.labeltext.."]";
	end

	local function form_render_tech_entry(idx, btnname, label, xstart, img)
		form = form .. "image_button["
						..(FORM.ENTRY_START_X+xstart)..","..(tech_start_y + idx*tech_line_h - 0.2)..";1,1;"
						..img..";"
						..btnname..";"
						.."]"
		form = form .. "label["
					..(FORM.ENTRY_START_X+xstart+1)..","..(tech_start_y + idx*tech_line_h)
					..";"..label.."]";
	end

	form = form .. "label["
					..(FORM.ENTRY_START_X)..","..(tech_start_y+0.2)
					..";"..formdef.bt1.catlabel.."]";
	for idx,entry in ipairs(formdef.bt1.entries) do
		local btnname,label,img = formdef.bt1.func(entry, idx)
		form_render_tech_entry(idx, btnname, label, 0, img)
	end
	form = form .. "label["
					..(FORM.ENTRY_START_X+third_width)..","..(tech_start_y+0.2)
					..";"..formdef.bt2.catlabel.."]";
	for idx,entry in ipairs(formdef.bt2.entries) do
		local btnname,label,img = formdef.bt2.func(entry, idx)
		form_render_tech_entry(idx, btnname, label, third_width, img)
	end
	form = form .. "label["
					..(FORM.ENTRY_START_X+2*third_width)..","..(tech_start_y+0.2)
					..";"..formdef.bt3.catlabel.."]";
	for idx,entry in ipairs(formdef.bt3.entries) do
		local btnname,label,img = formdef.bt3.func(entry, idx)
		form_render_tech_entry(idx, btnname, label, 2*third_width, img)
	end
	
	if formdef.add_btn_name then
		form = form .. "button["
				..(FORM.ENTRY_END_X-4.5)..","..(FORM.ENTRY_START_Y)..";4,1;"
				..formdef.add_btn_name..";"
				..formdef.add_btn_label.."]"
	end

	return form
end
