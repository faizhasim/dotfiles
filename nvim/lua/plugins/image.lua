return {
  {
    "3rd/image.nvim",
    build = false,
    opts = {
      -- backend = "sixel", -- because zellij didn't support kitty protocol (and hacky-ish tmux too)
      processor = "magick_cli",
    },
  },
}
