_: {
  brews = [
    # ──────────────────────────────────────────────
    # 🔧 Developer Tooling
    # ──────────────────────────────────────────────
    "markdownlint-cli2"
    "datadog-labs/pack/pup"

    # ──────────────────────────────────────────────
    # 💻 macOS Enhancement
    # ──────────────────────────────────────────────
    "felixkratz/formulae/borders" # borders
  ];
  casks = [
    # ──────────────────────────────────────────────
    # 🌐 Browsers
    # ──────────────────────────────────────────────
    "firefox" # because chromium can't be shared in teams...
    "microsoft-edge"

    # ──────────────────────────────────────────────
    # 💬 Communication
    # ──────────────────────────────────────────────
    "signal"

    # ──────────────────────────────────────────────
    # 🔑 Security & Productivity
    # ──────────────────────────────────────────────
    "1password"
    "obsidian" # zettelkasten
    "evernote" # notes
    "fantastical"

    # ──────────────────────────────────────────────
    # ✏️ Development — Editors
    # ──────────────────────────────────────────────
    "zed" # vim like editor
    "open-pencil/tap/open-pencil" # design editor compatible with Figma
    "jetbrains-toolbox" # manage jetbrains licenses

    # ──────────────────────────────────────────────
    # 🔬 Development — QuickLook Plugins
    # ──────────────────────────────────────────────
    "syntax-highlight" # quicklook syntax highlighter
    "qlmarkdown" # quicklook markdown

    # ──────────────────────────────────────────────
    # 🐳 Development — Containers
    # ──────────────────────────────────────────────

    # ──────────────────────────────────────────────
    # 🛠️ Development — Other Tooling
    # ──────────────────────────────────────────────

    # ──────────────────────────────────────────────
    # ⌨️ Keyboard & Input
    # ──────────────────────────────────────────────
    "karabiner-elements" # keyboard remap
    "homerow" # vimium for mac
    "chrysalis"

    # ──────────────────────────────────────────────
    # 🖥️ macOS Enhancement
    # ──────────────────────────────────────────────
    "sf-symbols" # patched font for sketchybar
    "thaw" # menu bar manager

    # ──────────────────────────────────────────────
    # 💽 Utilities
    # ──────────────────────────────────────────────

    # ──────────────────────────────────────────────
    # 🎬 Media
    # ──────────────────────────────────────────────

    # ──────────────────────────────────────────────
    # 🤖 AI
    # ──────────────────────────────────────────────

    # ──────────────────────────────────────────────
    # 📡 Networking
    # ──────────────────────────────────────────────

    # ──────────────────────────────────────────────
    # 🖧 Hardware
    # ──────────────────────────────────────────────
  ];
  taps = [
    # Snyk vulnerability scanner
    "snyk/tap"
    # Jira CLI
    "ankitpokhrel/jira-cli"
    # Borders (macOS window borders)
    "FelixKratz/formulae"
    # Datadog pack (internal tooling)
    "datadog-labs/pack"
  ];
  mas = [
    # ──────────────────────────────────────────────
    # 🛍️ Mac App Store
    # ──────────────────────────────────────────────
    1569813296 # 1Password for Safari — password autofill
    1193539993 # Brother iPrint&Scan — scanner driver
    441258766 # Magnet — window manager
    890031187 # Marked 2 — markdown preview
    1480933944 # Vimari — safari vim keys
  ];
}
