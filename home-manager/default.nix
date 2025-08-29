{ config, pkgs, lib, inputs, user, ... }: {
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ./packages.nix {};
    stateVersion = "23.11";
  };

  imports = [
    inputs._1password-shell-plugins.hmModules.default
    (import ./aerospace.nix { inherit config pkgs lib inputs user; })
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
    # plugins = with pkgs; [ gh ]; # disable gh integration and let gh uses osx keychain
  };

}
