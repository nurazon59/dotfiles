local wezterm = require("wezterm")
local act = wezterm.action

local function ime_abc_then_send(str)
	return wezterm.action_callback(function(window, pane)
		wezterm.run_child_process({ "/run/current-system/sw/bin/macism", "com.apple.keylayout.ABC" })
		window:perform_action(act.SendString(str), pane)
	end)
end

local keys = {
	{ key = "k", mods = "CMD", action = act.SendString("clear\r") },
	{ key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
	{ key = "w", mods = "CMD", action = act.QuitApplication },
	{ key = "t", mods = "CMD", action = act.SpawnWindow },
	{ key = "+", mods = "CMD", action = act.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "0", mods = "CMD", action = act.ResetFontSize },
	{ key = "f", mods = "CMD", action = act.ToggleFullScreen },
	{ key = "1", mods = "CMD", action = act.SendString("\x1b[1;9P") },
	{ key = "2", mods = "CMD", action = act.SendString("\x1b[1;9Q") },
	{ key = "3", mods = "CMD", action = act.SendString("\x1b[1;9R") },
	{ key = "4", mods = "CMD", action = act.SendString("\x1b[1;9S") },
	{ key = "5", mods = "CMD", action = act.SendString("\x1b[15;9~") },
	{ key = "6", mods = "CMD", action = act.SendString("\x1b[17;9~") },
	{ key = "7", mods = "CMD", action = act.SendString("\x1b[18;9~") },
	{ key = "8", mods = "CMD", action = act.SendString("\x1b[19;9~") },
	{ key = "9", mods = "CMD", action = act.SendString("\x1b[20;9~") },
	{ key = "t", mods = "CTRL", action = ime_abc_then_send("\x14") },
	{ key = "h", mods = "CTRL", action = ime_abc_then_send("\x08") },
	{ key = "j", mods = "CTRL", action = ime_abc_then_send("\x0a") },
	{ key = "k", mods = "CTRL", action = ime_abc_then_send("\x0b") },
	{ key = "l", mods = "CTRL", action = ime_abc_then_send("\x0c") },
	{ key = "Return", mods = "SHIFT", action = act.SendString("\n") },
}

local colors = {
	foreground = "#e0def4",
	background = "#191724",
	cursor_bg = "#524f67",
	cursor_fg = "#e0def4",
	cursor_border = "#524f67",
	selection_fg = "#e0def4",
	selection_bg = "#403d52",
	ansi = {
		"#26233a",
		"#eb6f92",
		"#31748f",
		"#f6c177",
		"#9ccfd8",
		"#c4a7e7",
		"#ebbcba",
		"#e0def4",
	},
	brights = {
		"#6e6a86",
		"#eb6f92",
		"#31748f",
		"#f6c177",
		"#9ccfd8",
		"#c4a7e7",
		"#ebbcba",
		"#e0def4",
	},
}

return {
	term = "xterm-256color",
	keys = keys,
	colors = colors,
	window_background_opacity = 0.95,
	text_background_opacity = 1.0, -- Make text background fully opaque to keep text color consistent
	font_size = 11.0,
	font = wezterm.font_with_fallback({
		"0xProto Nerd Font Mono",
		"JetBrains Mono",
		"PlemolJP Console NF",
	}),
	hide_tab_bar_if_only_one_tab = true,
	window_decorations = "RESIZE",
	send_composed_key_when_right_alt_is_pressed = false,
	use_ime = true,
}
