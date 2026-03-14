{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # NOTE: Using raw TOML configuration instead of Nix-generated config.
  # The Nix module for AeroSpace produces TOML with incorrect indentation
  # that breaks AeroSpace parsing. See: ./aerospace/aerospace.toml
  #
  # To enable the Nix module instead (if upstream is fixed), set:
  #   programs.aerospace.enable = true;
  #   programs.aerospace.userSettings = { ... };
  #
  # Previous Nix module configuration available at:
  # https://github.com/faizhasim/dotfiles/blob/5b4d20c29018f24f633e45c28eaa839a1ff710b5/home-manager/aerospace.nix

  home.file.".config/aerospace/aerospace.toml".text = builtins.readFile ./aerospace/aerospace.toml;
}
