{ hostname, ... }:

let
  common = import ./common.nix { };
  machineSpecific = import ./${hostname}.nix { };
in
{
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    # will not be uninstalled when removed
    # masApps = {
    #   Xcode = 497799835;
    #   Transporter = 1450874784;
    #   VN = 1494451650;
    # };
    onActivation = {
      # "zap" removes manually installed brews and casks
      cleanup = "zap";
      # cleanup = "none";
      autoUpdate = true;
      upgrade = true;
    };

    brews = common.brews ++ machineSpecific.brews;
    casks = common.casks ++ machineSpecific.casks;
    taps = common.taps ++ machineSpecific.taps;
    masApps = {
      "Brother iPrint&Scan" = 1193539993;
      "Marked 2" = 890031187;
      Magnet = 441258766;
      #      Notability = 360593530; # unsure why homebrew kept installing this
      #      Whatsapp = 310633997; # unsure why homebrew kept installing this
    };

  };

  # Workaround for corporate MDM scripts that check Homebrew version via git refs.
  # Some MDM scripts incorrectly check Homebrew's version by examining git refs
  # instead of using 'brew --version'. When Homebrew auto-updates, it sometimes
  # leaves the repo in a detached HEAD state without a stable branch ref, causing
  # these MDM scripts to fail.
  #
  # This activation script ensures the stable branch ref exists and points to the
  # latest tagged release. Runs after "homebrew" due to alphabetical ordering.
  system.activationScripts.homebrewMdmFix.text = ''
    echo >&2 "Ensuring Homebrew git stable branch ref..."
    
    if [ -d "/opt/homebrew/.git" ]; then
      cd "/opt/homebrew" && \
      git rev-parse $(git describe --tags $(git rev-list --tags --max-count=1)) \
      > .git/refs/heads/stable 2>/dev/null || true
      
      if [ $? -eq 0 ]; then
        echo >&2 "  ✓ Homebrew stable branch ref updated"
      else
        echo >&2 "  ⚠ Could not update Homebrew stable branch ref (non-fatal)"
      fi
    else
      echo >&2 "  ℹ Homebrew .git directory not found, skipping"
    fi
  '';

  system.activationScripts.masApps.text = ''
    echo "Running masApps workaround script..."

    # Check if mas is available
    if command -v mas &> /dev/null; then
      echo "Installing MAS apps manually"
      mas install 360593530  # Notability
      mas install 310633997  # Whatsapp
    else
      echo "mas CLI not found"
    fi
  '';
}
