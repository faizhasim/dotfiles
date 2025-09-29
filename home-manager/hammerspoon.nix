{ config, pkgs, lib, inputs, ... }:
let
  spoons = [
    {
      name = "ClipboardTool";
      url = "https://github.com/Hammerspoon/Spoons/raw/master/Spoons/ClipboardTool.spoon.zip";
      # sha256 = "sha256-15jqrc2xn3s8c3j7rlv50hwpf4x756n1fpqpdbvimk5vg7lifrhz";
      sha256 = "sha256-H2YX6Xm7zBr3ahdfF6wppxN3OQRl03zkYEgP2wXLWJY";
    }
  ];

  spoonPkgs = builtins.listToAttrs (map (spoon: {
    name = spoon.name;
    value = pkgs.fetchzip {
      url = spoon.url;
      sha256 = spoon.sha256;
    };
  }) spoons);

in {
  home.file = builtins.listToAttrs (map (spoon: {
    name = ".config/hammerspoon/Spoons/${spoon.name}.spoon";
    value.source = spoonPkgs.${spoon.name};
  }) spoons);

  # system.defaults.CustomUserPreferences."org.hammerspoon.Hammerspoon".MJConfigFile = "${config.home.homeDirectory}/.hammerspoon/init.lua";

  xdg.configFile."hammerspoon/init.lua".source = ./hammerspoon/init.lua;
}
