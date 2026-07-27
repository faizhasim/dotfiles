{
  config,
  pkgs,
  lib,
  inputs,
  hostname,
  username,
  nord-dircolors,
  aiHarnessModelProfile,
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
      "$HOME/.local/share/pnpm/bin" # pnpm v11+ global bins
      "$HOME/.local/bin" # custom CLIs like `idea`
      "$HOME/.bun/bin" # bun global installs (opencode, openpencil, etc.)
    ];

    stateVersion = "23.11";

    sessionVariables = {
      # NH_FLAKE: tell nh which flake to operate on (no path needed in nh commands)
      NH_FLAKE = "${config.home.homeDirectory}/dev/faizhasim/dotfiles";
    };
  };

  imports = [
    inputs._1password-shell-plugins.hmModules.default
    inputs.nix-index-database.homeModules.default
    inputs.krewfile.homeManagerModules.krewfile
    inputs.worktrunk.homeModules.default
    ./1password.nix
    ./aerospace.nix
    ./cargo.nix
    ./dircolors.nix
    ./direnv.nix
    ./dnsmasq.nix
    ./gh-dash.nix
    ./gh.nix
    ./herdr.nix
    ./hindsight.nix
    ./git.nix
    ./idea.nix
    ./jankyborders.nix
    ./karabiner-elements.nix
    ./krewfile.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./mise.nix
    ./npmrc.nix
    ./oh-my-pi.nix
    ./opencode.nix
    ./presenterm.nix
    ./qmd.nix
    ./shell.nix
    ./starship.nix
    ./vscode.nix
    ./wezterm.nix
    ./worktrunk.nix
    ./zsh.nix
  ];

  programs._1password-shell-plugins = {
    enable = true;
    plugins = [ ]; # gh removed — using native OAuth + Keychain
  };

}
