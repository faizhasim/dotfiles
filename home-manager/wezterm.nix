{ config, pkgs, lib, inputs, ... }: {
 programs.wezterm = {
  enable = true;
  enableZshIntegration = true;
  enableBashIntegration = true;
  extraConfig = builtins.readFile ./wezterm/wezterm.lua;
 };
}