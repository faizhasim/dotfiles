return {
  -- using snacks.image
  -- {
  --   "3rd/image.nvim",
  --   build = false,
  --   opts = {
  --     -- backend = "sixel", -- because zellij didn't support kitty protocol (and hacky-ish tmux too)
  --     processor = "magick_cli",
  --   },
  -- },
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      -- add options here
      -- or leave it empty to use the default settings
      default = {
        -- file and directory options
        dir_path = "assets", ---@type string | fun(): string
        extension = "png", ---@type string | fun(): string
        file_name = "%Y-%m-%d-%H-%M-%S", ---@type string | fun(): string
        use_absolute_path = false, ---@type boolean | fun(): boolean
        relative_to_current_file = true, ---@type boolean | fun(): boolean

        -- logging options
        -- verbose = true, ---@type boolean | fun(): boolean

        -- template options
        -- template = "$FILE_PATH", ---@type string | fun(context: table): string
        -- url_encode_path = false, ---@type boolean | fun(): boolean
        -- relative_template_path = true, ---@type boolean | fun(): boolean
        -- use_cursor_in_template = true, ---@type boolean | fun(): boolean
        -- insert_mode_after_paste = true, ---@type boolean | fun(): boolean
        -- insert_template_after_cursor = true, ---@type boolean | fun(): boolean

        -- prompt options
        -- prompt_for_file_name = true, ---@type boolean | fun(): boolean
        -- show_dir_path_in_prompt = false, ---@type boolean | fun(): boolean

        -- base64 options
        -- max_base64_size = 10, ---@type number | fun(): number
        -- embed_image_as_base64 = false, ---@type boolean | fun(): boolean

        -- image options
        -- process_cmd = "", ---@type string | fun(): string
        process_cmd = "convert - -quality 75 png:-", ---@type string
        -- copy_images = false, ---@type boolean | fun(): boolean
        -- download_images = true, ---@type boolean | fun(): boolean
        -- formats = { "jpeg", "jpg", "png" }, ---@type string[]

        -- drag and drop options
        drag_and_drop = {
          enabled = true, ---@type boolean | fun(): boolean
          -- insert_mode = false, ---@type boolean | fun(): boolean
        },
      },
      -- filetype specific options
      filetypes = {
        markdown = {
          url_encode_path = true, ---@type boolean | fun(): boolean
          template = "![$LABEL$CURSOR]($FILE_PATH)", ---@type string | fun(context: table): string
          download_images = false, ---@type boolean | fun(): boolean
        },
      },
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    ft = "markdown",
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false, -- this will be removed in the next major release
      workspaces = {
        {
          name = "work",
          path = "/Users/faizhasim/Library/Mobile Documents/iCloud~md~obsidian/Documents/SEEK",
        },
      },
    },
  },
}
