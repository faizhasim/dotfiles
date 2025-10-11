{ config, pkgs, lib, inputs, hostname, username, nord-dircolors, ... }: {
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
    inputs.krewfile.homeManagerModules.krewfile
    (import ./aerospace.nix { inherit config pkgs lib inputs username; })
    ./direnv.nix
    (import ./dircolors.nix { inherit config pkgs lib inputs nord-dircolors; })
    ./espanso.nix
    ./gh-dash.nix
    ./gh.nix
    ./git.nix
    ./hammerspoon.nix
    ./jankyborders.nix
    ./krewfile.nix
    ./mise.nix
    ./npmrc.nix
    ./nvchad.nix
    ./shell.nix
    ./sketchybar.nix
    ./vscode.nix
    ./wezterm.nix
    ./zsh.nix
  ];

  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh ];
  };

}
