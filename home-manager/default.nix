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
      "$HOME/.local/share/pnpm" # pnpm v10 global bins (legacy)
      "$HOME/.local/share/pnpm/bin" # pnpm v11+ global bins
      "$HOME/.local/bin" # custom CLIs like `idea`
      "$HOME/.bun/bin" # bun global installs (opencode, openpencil, etc.)
      # "$HOME/.proto/bin"
    ];

    stateVersion = "23.11";
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
    plugins = [ ]; # gh removed — using native OAuth + Keychain
  };

}
