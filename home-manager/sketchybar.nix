{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.sketchybar = {
    enable = false; # using thaw instead
    service.enable = false; # using thaw instead
    config = {
      source = ./sketchybar;
      recursive = true;
    };
    configType = "bash";
  };
}
