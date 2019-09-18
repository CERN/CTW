-- Common template for the technology/idea/resource information formspec.
-- Helps with links and backlinks

--[[

This file forms a common template for the Ideas, Resources and Technologies formspecs. It helps with the
form layout and by providing a "formspec return stack" to go back to pages you visited earlier.

Using the Return Stack:

The Stack is acctually just composed of functions whose task is to open a form. When one form is
going to blast the user off to another form from its receive_fields callback, it must
push a function that re-opens the form that is currently open at the player, like:
		if fields.tech_tree then
			ctw_technologies.form_returnstack_push(pname, function(pname) ctw_technologies.show_technology_form(pname, techid) end)
			ctw_technologies.show_tech_tree(pname, 0)
		end

Additionally, it is in the responsibility of the using formspec implementations to call the back button action
and clear the stack on form quit, as follows:
		if fields.goto_back then
			ctw_technologies.form_returnstack_pop(pname)
		end
		
		if fields.quit then
			ctw_technologies.form_returnstack_clear(pname)
		end
]]--


local returnstack = {}
	
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
local tech_line_h = 1

local function form_render_tech_entries(form, xstart, tech_start_y, bt)
	if not bt then return end
	form = form .. "label["
					..(FORM.ENTRY_START_X+xstart)..","..(tech_start_y+0.2)
					..";"..bt.catlabel.."]";
	for idx,entry in ipairs(bt.entries) do
		local btnname,label,img = bt.func(entry, idx)
		local itembtn = bt.use_item_image_button and "item_" or ""

		form = form .. itembtn.."image_button["
						..(FORM.ENTRY_START_X+xstart)..","..(tech_start_y + idx*tech_line_h - 0.2)..";1,1;"
						..img..";"
						..btnname..";"
						.."]"
		form = form .. "label["
					..(FORM.ENTRY_START_X+xstart+1)..","..(tech_start_y + idx*tech_line_h)
					..";"..label.."]";
	end
	return form
end


function ctw_technologies.get_detail_formspec(formdef, pname)
	local n_tech_lines = 0
	if formdef.bt1 then n_tech_lines = math.max(n_tech_lines, #formdef.bt1.entries) end
	if formdef.bt2 then n_tech_lines = math.max(n_tech_lines, #formdef.bt2.entries) end
	if formdef.bt3 then n_tech_lines = math.max(n_tech_lines, #formdef.bt3.entries) end
	

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


	form = form_render_tech_entries(form, 0, tech_start_y, formdef.bt1)
	form = form_render_tech_entries(form, third_width, tech_start_y, formdef.bt2)
	form = form_render_tech_entries(form, 2*third_width, tech_start_y, formdef.bt3)
	
	
	if formdef.add_btn_name then
		form = form .. "button["
				..(FORM.ENTRY_END_X-4.5)..","..(FORM.ENTRY_START_Y)..";3,1;"
				..formdef.add_btn_name..";"
				..formdef.add_btn_label.."]"
	end
	
	if returnstack[pname] and #returnstack[pname]>0 then
		form = form .. "button["
				..(FORM.ENTRY_END_X-1.5)..","..(FORM.ENTRY_START_Y)..";1.5,1;"
				.."goto_back;"
				.."<< Back]"
	end
	
	return form
end


-- Push a function to re-open the just left form on the return stack
-- func(pname)
function ctw_technologies.form_returnstack_push(pname, form_open_func)
	if not returnstack[pname] then
		returnstack[pname] = {}
	end
	table.insert(returnstack[pname], form_open_func)
end

-- Open last visited form to player
function ctw_technologies.form_returnstack_pop(pname)
	local rs = returnstack[pname]
	if not rs or #rs<1 then
		return
	end
	local fun = rs[#rs]
	rs[#rs]=nil
	fun(pname)
end

-- On form quit, clear the return stack
function ctw_technologies.form_returnstack_clear(pname)
	returnstack[pname] = nil
end






