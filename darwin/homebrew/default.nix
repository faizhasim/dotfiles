{ hostname, ... }:

let
  common = import ./common.nix { };
  machineSpecific = import ./${hostname}.nix { };
in
{
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

    brews = common.brews ++ machineSpecific.brews;
    casks = common.casks ++ machineSpecific.casks;
    taps = common.taps ++ machineSpecific.taps;

  };
}
