local wezterm = require 'wezterm'
--local commands = require 'commands'

local config = wezterm.config_builder()

-- Font settings
config.font_size = 14
config.line_height = 1.2
config.font = wezterm.font_with_fallback {
    {
        family = 'JetBrains Mono',
        harfbuzz_features = {
            'calt',
            'ss01',
            'ss02',
            'ss03',
            'ss04',
            'ss05',
            'ss06',
            'ss07',
            'ss08',
            'ss09',
            'liga',
        },
    },
    { family = 'Symbols Nerd Font Mono' },
}
config.font_rules = {
    {
        font = wezterm.font('JetBrains Mono', {
            bold = true,
        }),
    },
    {
        italic = true,
        font = wezterm.font('JetBrains Mono', {
            italic = true,
        }),
    },
}

-- Colors
config.color_scheme = 'Nord (base16)'

-- Appearance
config.cursor_blink_rate = 0
config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
    left = '1cell',
    right = '1cell',
    top = '0.5cell',
    bottom = '0.5cell',
}
config.window_background_opacity = 0.8
config.macos_window_background_blur = 20

-- Miscellaneous settings
config.max_fps = 120
config.prefer_egl = true

-- Enable kitty keyboard protocol for better keyboard support in terminal multiplexers
config.enable_kitty_keyboard = true

config.window_frame = {
  inactive_titlebar_bg = '#2E3440',            -- polar night (base)
  active_titlebar_bg = '#3B4252',              -- polar night (slightly lighter)
  inactive_titlebar_fg = '#D8DEE9',            -- snow storm (dim text)
  active_titlebar_fg = '#ECEFF4',              -- snow storm (bright text)
  inactive_titlebar_border_bottom = '#4C566A', -- polar night (border)
  active_titlebar_border_bottom = '#81A1C1',   -- frost (blue accent)
  button_fg = '#D8DEE9',                       -- snow storm
  button_bg = '#434C5E',                       -- polar night (mid tone)
  button_hover_fg = '#ECEFF4',                 -- snow storm bright
  button_hover_bg = '#4C566A',                 -- polar night (lighter hover)
}


-- Key bindings replicating iTerms because I'm used to it instead of tmux
config.keys = {
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = '[',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection 'Prev',
  },
  {
    key = ']',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection 'Next',
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.DisableDefaultAssignment,
  },
  -- support Mac jump words
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = wezterm.action{ SendString="\x1bb" },
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action{ SendString="\x1bf" },
  },

}

-- Custom commands
--wezterm.on('augment-command-palette', function()
--    return commands
--end)

return config
