_: {
  brews = [
    # ──────────────────────────────────────────────
    # 🔧 Developer Tooling
    # ──────────────────────────────────────────────
    "markdownlint-cli2"
    "datadog-labs/pack/pup"
    # "pkgxdev/made/pkgx" # run anything
    # "cocoapods" # ios development
    # "ios-deploy" # ios development
    # "ruff" # python linter
    # "totp-cli" # for backstage e2e tests

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
    # "arc" # mac browser

    # ──────────────────────────────────────────────
    # 💬 Communication
    # ──────────────────────────────────────────────
    "signal"
    # "microsoft-teams"
    # "microsoft-auto-update"

    # ──────────────────────────────────────────────
    # 🔑 Security & Productivity
    # ──────────────────────────────────────────────
    "1password"
    "obsidian" # zettelkasten
    "evernote" # notes
    "fantastical"
    # "linear-linear" # task management
    # "meetingbar" # shows upcoming meetings

    # ──────────────────────────────────────────────
    # ✏️ Development — Editors
    # ──────────────────────────────────────────────
    "zed" # vim like editor
    "open-pencil/tap/open-pencil" # design editor compatible with Figma
    "jetbrains-toolbox" # manage jetbrains licenses
    # "visual-studio-code" # code editor

    # ──────────────────────────────────────────────
    # 🔬 Development — QuickLook Plugins
    # ──────────────────────────────────────────────
    "syntax-highlight" # quicklook syntax highlighter
    "qlmarkdown" # quicklook markdown

    # ──────────────────────────────────────────────
    # 🐳 Development — Containers
    # ──────────────────────────────────────────────
    # "docker" # docker desktop # part of enterprise offering
    # "freelens" # kubernetes IDE

    # ──────────────────────────────────────────────
    # 🛠️ Development — Other Tooling
    # ──────────────────────────────────────────────
    # "postman"

    # ──────────────────────────────────────────────
    # ⌨️ Keyboard & Input
    # ──────────────────────────────────────────────
    "karabiner-elements" # keyboard remap
    "homerow" # vimium for mac
    "chrysalis"
    # "eurkey" # keyboard layout

    # ──────────────────────────────────────────────
    # 🖥️ macOS Enhancement
    # ──────────────────────────────────────────────
    "sf-symbols" # patched font for sketchybar
    "thaw" # menu bar manager
    # "alfred" - experimenting spotlight tahoe
    # "hiddenbar" # hides menu bar icons
    # "raycast" # launcher on steroids # TODO: Stay with Alfred for now
    # "keycastr" # show keystrokes on screen
    # "loop" # window manager
    # "aldente" # battery management

    # ──────────────────────────────────────────────
    # 💽 Utilities
    # ──────────────────────────────────────────────
    # "the-unarchiver"
    # "raspberry-pi-imager" # flash images to sd card
    # "balenaetcher" # usb flashing
    # "spacedrive" # file explorer
    # "macfuse" # file system utilities

    # ──────────────────────────────────────────────
    # 🎬 Media
    # ──────────────────────────────────────────────
    # "vlc" # media player
    # "iina" # media player

    # ──────────────────────────────────────────────
    # 🤖 AI
    # ──────────────────────────────────────────────
    # "chatgpt" # open ai desktop client
    # "jan" # local ChatGPT

    # ──────────────────────────────────────────────
    # 📡 Networking
    # ──────────────────────────────────────────────
    # "wireshark" # network sniffer

    # ──────────────────────────────────────────────
    # 🖧 Hardware
    # ──────────────────────────────────────────────
    # "displaylink" # connect to external dell displays
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
    "open-pencil/tap"

    # --- Commented / Disabled taps ---
    # "acrogenesis/macchanger"
    # "databricks/tap" # databricks
    # "pkgxdev/made" # pkgx
    # "nikitabobko/tap" # aerospace
    # "freelensapp/tap" # freelens
    # "mediosz/tap"
  ];
}
