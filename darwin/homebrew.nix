{ ... }: {
  homebrew = {
    enable = true;
    global = { autoUpdate = false; };
    # will not be uninstalled when removed
    # masApps = {
    #   Xcode = 497799835;
    #   Transporter = 1450874784;
    #   VN = 1494451650;
    # };
    onActivation = {
      # "zap" removes manually installed brews and casks
      cleanup = "zap";
#      cleanup = "none";
      autoUpdate = false;
      upgrade = false;
    };
    brews = [
      "pkgxdev/made/pkgx" # run anything
      "seek-jobs/tools/awsauth"
      "seek-jobs/tools/gantry"
      # Automat formula might be downloaded from s3 bucket, which is annoying. It needs awsauth.
      "seek-jobs/tools/automat"
      "seek-jobs/tools/automat@1.0.0-alpha.3"

      # ios development
#      "cocoapods"
#      "ios-deploy"

      # work
#      "ruff" # python linter
#      "totp-cli" # for backstage e2e tests
    ];
    casks = [
      # utilities
#      "aldente" # battery management
#      "macfuse" # file system utilities
      "hiddenbar" # hides menu bar icons
#      "meetingbar" # shows upcoming meetings
#      "karabiner-elements" # keyboard remap
#      "eurkey" # keyboard layout
#      "displaylink" # connect to external dell displays
#      "raspberry-pi-imager" # flash images to sd card

      # coding
#      "intellij-idea"
#      "postman"

      # virtualization
#      "docker" # docker desktop # part of enterprise offering

      # communication
#      "microsoft-teams"
#      "microsoft-auto-update"
      "microsoft-outlook"
#      "zoom" # managed by MDM
      # "slack"
      "signal"
#      "discord"

      "obs" # stream / recoding software
#      "the-unarchiver"
#      "wireshark" # network sniffer
      "sf-symbols" # patched font for sketchybar
      # "raycast" # launcher on steroids # TODO: Stay with Alfred for now
#      "keycastr" # show keystrokes on screen
      "obsidian" # zettelkasten
#      "arc" # mac browser
#      "google-chrome" # used for selenium and testing
#      "visual-studio-code" # code editor
      "zed" # vim like editor
      "vlc" # media player
#      "iina" # media player
#      "linear-linear" # task management
#      "balenaetcher" # usb flashing
#      "spacedrive" # file explorer
#      "steam" # gaming
#      "chatgpt" # open ai desktop client
#      "loop" # window manager
#      "homerow" # vimium for mac
#      "ghostty" # terminal
#      "jan" # local ChatGPT
      "firefox" # because chromium can't be shared in teams...
#      "todoist" # better reminders
#      "battle-net" # some fun
      # "neohtop" # nice htop gui alternative
#      "freelens" # kubernetes IDE
    ];
    taps = [
      "acrogenesis/macchanger"
      "snyk/tap"
      "ankitpokhrel/jira-cli"
      # custom
#      "FelixKratz/formulae" # borders
#      "databricks/tap" # databricks
      "pkgxdev/made" # pkgx
#      "nikitabobko/tap" # aerospace
#      "freelensapp/tap" # freelens
      {
        name = "SEEK-Jobs/tools"; # remove and re-apply after configuring git ssh if this won't work
        clone_target = "git@github.com:SEEK-Jobs/homebrew-tools.git";
        force_auto_update = true;
      }
    ];
  };
}