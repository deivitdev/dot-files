-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = "Tokyo Night"
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 13

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 1.0
config.macos_window_background_blur = 10

wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local process_name = pane:get_foreground_process_name()
	if process_name and (process_name:find("nvim") or process_name:find("vim")) then
		overrides.window_background_opacity = 0.8
	else
		overrides.window_background_opacity = 1.0
	end
	window:set_config_overrides(overrides)
end)

config.keys = {
	-- Allow Cmd-V to paste from the system clipboard
	{
		key = "v",
		mods = "CMD",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	-- Allow Cmd-C to copy (if you use the mouse to select)
	{
		key = "c",
		mods = "CMD",
		action = wezterm.action.CopyTo("Clipboard"),
	},
}

-- and finally, return the configuration to wezterm
return config
