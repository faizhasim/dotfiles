{
  config,
  pkgs,
  lib,
  inputs,
  hostname,
  username,
  nord-dircolors,
  opencodeModelProfile,
  ...
}:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    packages =
      let
        common = import ./packages/common.nix { inherit pkgs; };
        machineSpecific = import ./packages/${hostname}.nix { inherit pkgs; };
      in
      common ++ machineSpecific;
    sessionPath = [
      "$HOME/.local/share/pnpm" # pnpm global binaries
      "$HOME/.local/bin" # custom CLIs like `idea`
      # "$HOME/.proto/bin"
    ];

    stateVersion = "23.11";
  };

  imports = [
    inputs._1password-shell-plugins.hmModules.default
    inputs.krewfile.homeManagerModules.krewfile
    inputs.worktrunk.homeModules.default
    (import ./aerospace.nix {
      inherit
        config
        pkgs
        lib
        inputs
        username
        ;
    })
    ./direnv.nix
    (import ./dircolors.nix {
      inherit
        config
        pkgs
        lib
        inputs
        nord-dircolors
        ;
    })
    ./dnsmasq.nix
    ./gh-dash.nix
    ./gh.nix
    ./git.nix
    ./idea.nix
    ./jankyborders.nix
    ./karabiner-elements.nix
    ./krewfile.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./mise.nix
    ./npmrc.nix
    (import ./opencode.nix { inherit lib inputs opencodeModelProfile; })
    ./presenterm.nix
    ./shell.nix
    ./sketchybar.nix
    ./starship.nix
    ./vscode.nix
    ./wezterm.nix
    ./worktrunk.nix
    ./zellij.nix
    ./zsh.nix
  ];

  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh ];
  };

}
