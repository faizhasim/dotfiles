# Worktrunk configuration using official home-manager module
# See: https://github.com/max-sixty/worktrunk
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Enable worktrunk with official home-manager module
  # This handles shell integration automatically
  programs.worktrunk = {
    enable = true;
    enableZshIntegration = true;
    # package is provided by the module via worktrunk-pkgs parameter
  };

  # Link external TOML config to XDG config directory
  # Using external file (not embedded) for easier editing and version control
  xdg.configFile."worktrunk/config.toml".source = ./worktrunk/config.toml;
}
