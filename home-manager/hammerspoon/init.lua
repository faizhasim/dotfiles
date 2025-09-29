hs.loadSpoon("ClipboardTool")

spoon.ClipboardTool.deduplicate = true
spoon.ClipboardTool.hist_size = 200
spoon.ClipboardTool.frequency = 1.0
spoon.ClipboardTool.display_max_length = 60
spoon.ClipboardTool.paste_on_select = true
spoon.ClipboardTool.show_in_menubar = false
spoon.ClipboardTool.show_copied_alert = false

-- Start it
spoon.ClipboardTool:start()

spoon.ClipboardTool:bindHotkeys({
  toggle_clipboard = { { "cmd", "shift" }, "c" }
})

