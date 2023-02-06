local wezterm = require("wezterm")

local fonts = {
	cartograph = {
		font = {
			family = "Iosevka Nerd Font",
			weight = "Medium",
			harfbuzz_features = {
				"cv06=1",
				"cv14=1",
				"cv32=1",
				"ss04=1",
				"ss07=1",
				"ss09=1",
			},
		},
		size = 18,
		font_rules = {
			italics = true,
		},
	},
}

local function get_font(name)
	return {
		font = wezterm.font_with_fallback({
			fonts[name].font,
			{ family = "Sarasa UI SC", weight = "Medium" },
			"Noto Color Emoji",
		}),
		size = fonts[name].size,
	}
end

local function numberStyle(number, script)
	local scripts = {
		superscript = {
			"\\u2070",
			"\\u00b9",
			"\\u00b2",
			"\\u00b3",
			"\\u2074",
			"\\u2075",
			"\\u2076",
			"\\u2077",
			"\\u2078",
			"\\u2079",
		},
		subscript = {
			"\\u2080",
			"\\u2081",
			"\\u2082",
			"\\u2083",
			"\\u2084",
			"\\u2085",
			"\\u2086",
			"\\u2087",
			"\\u2088",
			"\\u2089",
		},
	}
	local numbers = scripts[script]
	local number_string = tostring(number)
	local result = ""
	for i = 1, #number_string do
		local char = number_string:sub(i, i)
		local num = tonumber(char)
		if num then
			result = result .. numbers[num + 1]
		else
			result = result .. char
		end
	end
	return result
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local RIGHT_DIVIDER = utf8.char(0xe0bc)
	local colours = config.resolved_palette.tab_bar

	local active_tab_index = 0
	for _, t in ipairs(tabs) do
		if t.is_active == true then
			active_tab_index = t.tab_index
		end
	end

	-- local active_bg = colours.active_tab.bg_color
	local active_bg = config.resolved_palette.ansi[6]
	-- local active_fg = colours.background
	local active_fg = "#000000"
	local inactive_bg = colours.inactive_tab.bg_color
	local inactive_fg = colours.inactive_tab.fg_color
	local new_tab_bg = colours.new_tab.bg_color

	local s_bg, s_fg, e_bg, e_fg

	if tab.tab_index == #tabs - 1 then
		if tab.is_active then
			s_bg = active_bg
			s_fg = active_fg
			e_bg = new_tab_bg
			e_fg = active_bg
		else
			s_bg = inactive_bg
			s_fg = inactive_fg
			e_bg = new_tab_bg
			e_fg = inactive_bg
		end
	elseif tab.tab_index == active_tab_index - 1 then
		s_bg = inactive_bg
		s_fg = inactive_fg
		e_bg = active_bg
		e_fg = inactive_bg
	elseif tab.is_active then
		s_bg = active_bg
		s_fg = active_fg
		e_bg = inactive_bg
		e_fg = active_bg
	else
		s_bg = inactive_bg
		s_fg = inactive_fg
		e_bg = inactive_bg
		e_fg = inactive_bg
	end

	local muxpanes = wezterm.mux.get_tab(tab.tab_id):panes()
	local count = #muxpanes == 1 and "" or #muxpanes

	return {
		{ Background = { Color = s_bg } },
		{ Foreground = { Color = s_fg } },
		{
			Text = " "
				.. tab.tab_index + 1
				.. ": "
				.. tab.active_pane.title
				.. numberStyle(count, "superscript")
				.. " ",
		},
		{ Background = { Color = e_bg } },
		{ Foreground = { Color = e_fg } },
		{ Text = RIGHT_DIVIDER },
	}
end)

wezterm.on("update-status", function(window, pane)
	local palette = window:effective_config().resolved_palette
	local firstTabActive = window:mux_window():tabs_with_info()[1].is_active

	local RIGHT_DIVIDER = utf8.char(0xe0b0)
	local text = "   "

	if window:leader_is_active() then
		text = "   "
	end

	local divider_bg = firstTabActive and palette.ansi[6] or palette.tab_bar.inactive_tab.bg_color

	window:set_left_status(wezterm.format({
		{ Foreground = { Color = "#000000" } },
		{ Background = { Color = palette.ansi[5] } },
		{ Text = text },
		{ Background = { Color = divider_bg } },
		{ Foreground = { Color = palette.ansi[5] } },
		{ Text = RIGHT_DIVIDER },
	}))
end)

local window_padding = {
	left = 10,
	right = 10,
	top = 5,
	bottom = 5,
}

-- Always return dark theme for now
local darkTheme = "Catppuccin Mocha"
local function scheme_for_appearance(appearance)
	-- if appearance:find("Dark") then
	-- 	return darkTheme
	-- else
	-- 	return "Catppuccin Latte"
	-- end
	return darkTheme
end

local font = get_font("cartograph")
local border_color = "#181825"
return {
	font = font.font,
	font_size = font.size,
	font_rules = fonts.font_rules,
	animation_fps = 60,
	text_background_opacity = 1,
	window_background_opacity = 0.95,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = false,
	hide_tab_bar_if_only_one_tab = false,
	tab_max_width = 50,

	window_decorations = "RESIZE",
	window_padding = window_padding,
	color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
	clean_exit_codes = { 130 },
	audible_bell = "Disabled",
	initial_cols = 132,
	initial_rows = 33,
	cursor_thickness = "2",
	window_frame = {
		border_left_width = "0.5cell",
		border_right_width = "0.5cell",
		border_top_height = "0.25cell",
		border_bottom_height = "0.25cell",
		border_left_color = border_color,
		border_right_color = border_color,
		border_bottom_color = border_color,
		border_top_color = border_color,
	},
}
