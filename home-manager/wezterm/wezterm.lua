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
config.color_scheme = 'Catppuccin Mocha'

-- Appearance
config.cursor_blink_rate = 0
-- config.window_decorations = 'RESIZE'
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

-- Custom commands
--wezterm.on('augment-command-palette', function()
--    return commands
--end)

return config