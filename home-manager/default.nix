{ config, pkgs, lib, inputs, hostname, username, ... }: {
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = let
      common = import ./packages/common.nix { inherit pkgs; };
      machineSpecific = import ./packages/${hostname}.nix { inherit pkgs; };
    in common ++ machineSpecific;

    stateVersion = "23.11";
  };

  imports = [
    inputs._1password-shell-plugins.hmModules.default
    (import ./aerospace.nix { inherit config pkgs lib inputs username; })
    ./direnv.nix
    ./gh.nix
    ./git.nix
    ./mise.nix
    ./npmrc.nix
    ./nvchad.nix
    ./shell.nix
    ./sketchybar.nix
    ./wezterm.nix
    ./zsh.nix
  ];

  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh ];
  };

}
