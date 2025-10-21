{ hostname, ... }:

let
  common = import ./common.nix { };
  machineSpecific = import ./${hostname}.nix { };
in
{
  homebrew = {
    enable = true;
    global = { autoUpdate = true; };
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
      autoUpdate = true;
      upgrade = true;
    };

    brews = common.brews ++ machineSpecific.brews;
    casks = common.casks ++ machineSpecific.casks;
    taps = common.taps ++ machineSpecific.taps;
    masApps = {
      "Brother iPrint&Scan" = 1193539993;
      "Marked 2" = 890031187;
#      Notability = 360593530; # unsure why homebrew kept installing this
#      Whatsapp = 310633997; # unsure why homebrew kept installing this
    };

  };

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
