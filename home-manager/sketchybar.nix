{ config, pkgs, lib, inputs, ... }: {
 programs.sketchybar = {
  enable = true;
  service.enable = true;
  config = {
    source = ./sketchybar;
    recursive = true;
  };
  configType = "bash";
 };
}