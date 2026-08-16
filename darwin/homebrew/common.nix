_: {
  brews = [
    # ──────────────────────────────────────────────
    # 🔧 Developer Tooling
    # ──────────────────────────────────────────────
    "markdownlint-cli2"
    "datadog-labs/pack/pup"
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
    "raycast" # productivity launcher

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
    # Datadog pack (internal tooling)
    "datadog-labs/pack"
  ];
  mas = {
    # ──────────────────────────────────────────────
    # 🛍️ Mac App Store
    # ──────────────────────────────────────────────
    "1Password for Safari" = 1569813296; # password autofill
    "Brother iPrint&Scan" = 1193539993; # scanner driver
    "Email" = 1489591003; # Edison Mail — delisted from MAS, keep while installed
    "Magnet" = 441258766; # window manager
    "Marked 2" = 890031187; # markdown preview
    "Vimari" = 1480933944; # safari vim keys
  };
}
