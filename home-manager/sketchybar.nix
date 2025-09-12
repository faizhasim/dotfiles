{ config, pkgs, lib, inputs, ... }: {
 programs.sketchybar = {
  enable = false; # use ice-bar instead
  service.enable = false; # use ice-bar instead
  config = {
    source = ./sketchybar;
    recursive = true;
  };
  configType = "bash";
 };
}