{ ... }: {
  brews = [
      # "pkgxdev/made/pkgx" # run anything

      # ios development
#      "cocoapods"
#      "ios-deploy"

      # work
#      "ruff" # python linter
#      "totp-cli" # for backstage e2e tests
      "felixkratz/formulae/borders" # borders
    ];
    casks = [
      "1password"
      # "alfred" - experimenting spotlight tahoe
      # utilities
#      "aldente" # battery management
#      "macfuse" # file system utilities
      # "hiddenbar" # hides menu bar icons
#      "meetingbar" # shows upcoming meetings
#      "karabiner-elements" # keyboard remap
#      "eurkey" # keyboard layout
#      "displaylink" # connect to external dell displays
#      "raspberry-pi-imager" # flash images to sd card

      # coding
#      "postman"

      # virtualization
#      "docker" # docker desktop # part of enterprise offering

      # communication
#      "microsoft-teams"
#      "microsoft-auto-update"
      "signal"

#      "the-unarchiver"
#      "wireshark" # network sniffer
      "sf-symbols" # patched font for sketchybar
      # "raycast" # launcher on steroids # TODO: Stay with Alfred for now
#      "keycastr" # show keystrokes on screen
      "obsidian" # zettelkasten
#      "arc" # mac browser
#      "visual-studio-code" # code editor
      "zed" # vim like editor
      # "vlc" # media player
#      "iina" # media player
#      "linear-linear" # task management
#      "balenaetcher" # usb flashing
#      "spacedrive" # file explorer
#      "chatgpt" # open ai desktop client
#      "loop" # window manager
#      "homerow" # vimium for mac
#      "ghostty" # terminal
#      "jan" # local ChatGPT
      "firefox" # because chromium can't be shared in teams...
#      "todoist" # better reminders
#      "freelens" # kubernetes IDE
      "evernote" # notes
      "syntax-highlight" # quicklook syntax highlighter
      "qlmarkdown" # quicklook markdown
      # "mediosz/tap/swipeaerospace" # swipe using three fingers
    ];
    taps = [
      # "acrogenesis/macchanger"
      "snyk/tap"
      "ankitpokhrel/jira-cli"
      "FelixKratz/formulae"
      # custom
#      "FelixKratz/formulae" # borders
#      "databricks/tap" # databricks
      # "pkgxdev/made" # pkgx
#      "nikitabobko/tap" # aerospace
#      "freelensapp/tap" # freelens
      # "mediosz/tap"
    ];
}
