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
      Notability = 360593530;
      Whatsapp = 310633997;
    };

  };
}
