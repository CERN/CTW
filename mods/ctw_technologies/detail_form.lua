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
			ctw_technologies.form_returnstack_push(pname, function(pname2)
				ctw_technologies.show_technology_form(pname2, techid) end)
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
FORM.WIDTH = 14
FORM.HEIGHT = 9

-- Function to render button columns; "bt1", "bt2" and "bt3"
local function form_render_entries(team, inv, bt, width)
	local btn_prefix = bt.prefix or ""
	local fs = {
		("label[0,0;%s]"):format(bt.catlabel or "nil")
	}
	local y = 0.75

	for _, entry in pairs(bt.entries) do
		local description
		if bt.type == "reference" then
			local istack = ItemStack(entry)
			local idef = minetest.registered_items[istack:get_name()] or {}
			description = idef.description or istack:get_name()

			fs[#fs + 1] = (
				"item_image_button[0,%f;1,1;%s;%s;]" ..
				"label[0.6,%f;%i]" -- Item count
			):format(
				y, istack:get_name(), btn_prefix .. (idef._ctw_reference_id or "error"),
				y + 0.45, tostring(istack:get_count())
			)
		elseif bt.type == "technology" then
			local tech = ctw_technologies.get_technology(entry)
			local state = ctw_technologies.get_team_tech_state(entry, team)
			local texture = "ctw_technologies_technology.png"
			if state.state == "gained" then
				texture = texture .. "^ctw_technologies_gained.png"
			end
			description = tech.name

			fs[#fs + 1] = ("image_button[0,%f;1,1;%s;%s;]"):format(
				y, texture, btn_prefix .. entry)
		elseif bt.type == "benefit" then
			-- Entry = tech ID
			local image, desc = ctw_technologies.render_benefit(entry)
			description = desc

			fs[#fs + 1] = ("image[0,%f;1,1;%s]"):format(y, image)
		else
			assert("Unknown bt type: " .. (bt.type or "nil"))
		end

		if description then
			local y_offset = 0.2
			if description:len() > 30 then
				description = minetest.wrap_text(description, 30, false)
				y_offset = 0
			end
			fs[#fs + 1] = ("label[1,%f;%s]"):format(
				y + y_offset, minetest.formspec_escape(description))
		end
		y = y + 1
	end

	if #bt.entries == 0 then
		fs[#fs + 1] = ("label[0,%f;%s]"):format(y, "(none)")
	end
	return table.concat(fs), y
end


--[[ formdef = {
	bt1 = {
		catlabel = "Technologies required:",
		type = "reference",
		-- Possible values:
		--  "technology"
		--  "reference"
		--  "benefit"
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
function ctw_technologies.get_detail_formspec(formdef, pname)
	local team = teams.get(pname)
	local inv = minetest.get_player_by_name(pname)
	inv = inv and inv:get_inventory()

	local fs = {
		"size[" .. FORM.WIDTH .. "," .. FORM.HEIGHT .. "]",
		"real_coordinates[]",
		-- Green sidebar:
		"vertlabel[0.15,0.5;" .. formdef.vert_text .. "]",
		"box[0,0;0.5," .. FORM.HEIGHT .. ";#080]",
		-- Title:
		"label[1.1,0.2;" .. formdef.title .. "]"
	}

	-- Header buttons
	local TPL_BUTTON = "button[%f,%f;%f,%f;%s;%s]"

	if ctw_technologies.form_returnstack_exists(pname, 1) then
		fs[#fs + 1] = TPL_BUTTON:format(FORM.WIDTH - 1, 0,
			1, 1, "goto_forth", ">>")
	end

	if formdef.add_btn_name then
		fs[#fs + 1] = TPL_BUTTON:format(FORM.WIDTH - 4, 0,
			3, 1, formdef.add_btn_name, formdef.add_btn_label)
	end

	if ctw_technologies.form_returnstack_exists(pname, -1) then
		fs[#fs + 1] = TPL_BUTTON:format(FORM.WIDTH - 5, 0,
			1, 1, "goto_back", "<<")
	end

	local text_y = 1.1
	-- Add progress bar
	if formdef.progress then
		local width_max = FORM.WIDTH - 1 - 6

		fs[#fs + 1] = (
			"box[1,0;%f,0.8;#777]" ..
			"box[1.1,0.1;%f,0.6;#0F0]" ..
			"label[6,0.2;%s]"
		):format(
			width_max,
			width_max * formdef.progress.value - 0.2,
			"(" .. formdef.progress.text .. ")"
		)
	end

	-- Get button columns
	local button_cols = {}
	local button_maxheight = 0
	for i = 1, 3 do
		local bt = formdef["bt" .. i]
		if not bt then
			break
		end

		local fs2, y = form_render_entries(team, inv, bt, 4)
		button_cols[i] = fs2
		button_maxheight = math.max(button_maxheight, y)
	end

	local container_width = (FORM.WIDTH - 1) / #button_cols
	for i, bt in ipairs(button_cols) do
		-- Insert button columns
		fs[#fs + 1] = ("container[%f,%f]"):format(
			container_width * (i - 1) + 1, FORM.HEIGHT - button_maxheight)
		fs[#fs + 1] = bt -- Do not concat this
		fs[#fs + 1] = "container_end[]"
	end

	-- Add information text
	fs[#fs + 1] = doc.widgets.text(formdef.text, 1.2, text_y,
		FORM.WIDTH - 1.5, FORM.HEIGHT - button_maxheight - text_y - 0.25)

	return table.concat(fs)
end

function ctw_technologies.form_returnstack_exists(pname, offset)
	local stack = returnstack[pname] or {}
	if not stack.index then
		return false
	end

	return type(stack[stack.index + offset]) == "function"
end

function ctw_technologies.form_returnstack_move(pname, offset)
	local stack = returnstack[pname] or {}
	local index = (stack.index or 0) + offset

	if not stack[index] then
		return
	end

	stack.index = index
	returnstack[pname] = stack
	print("move:", dump(stack))
	return stack[index]()
end

function ctw_technologies.form_returnstack_push(pname, form_open_func)
	local stack = returnstack[pname] or {}
	local index = (stack.index or 0) + 1

	stack.index = index
	stack[index] = form_open_func

	-- Clean up garbage
	for i = index + 1, 99 do
		if not stack[i] then
			break
		end
		stack[i] = nil
	end

	returnstack[pname] = stack
	print("push:", dump(stack))
end

-- On form quit, clear the return stack
function ctw_technologies.form_returnstack_clear(pname)
	returnstack[pname] = nil
end






