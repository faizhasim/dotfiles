# Worktrunk configuration using official home-manager module
# See: https://github.com/max-sixty/worktrunk
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  # Worktrunk shell init captured at build time (avoids late eval in .zshrc).
  # runCommandLocal: always builds locally, never substituted — the output is
  # a deterministic text file, no reason to distribute via binary cache.
  worktrunkShellInit =
    pkgs.runCommandLocal "wt-shell-init.zsh"
      {
        nativeBuildInputs = [ pkgs.worktrunk ];
        meta.description = "Worktrunk zsh shell function with auto-cd";
      }
      ''
        wt config shell init zsh > $out
      '';

  # Wrapper that injects GH_TOKEN from 1Password before execing the real wt.
  # Worktrunk's shell function uses WORKTRUNK_BIN to decide what binary to run,
  # so setting this env var means every subprocess gets GH_TOKEN automatically.
  wtAuthWrapper = pkgs.writeShellScript "wt-auth-wrapper" ''
    GH_TOKEN=$(op read "op://Private/Github/Section_gy45mtjzrek6pbvq4hket7qtfq/token" 2>/dev/null) exec "${pkgs.worktrunk}/bin/wt" "$@"
  '';
in
{
  # Link external TOML config to XDG config directory
  # Using external file (not embedded) for easier editing and version control
  xdg.configFile."worktrunk/config.toml".source = ./worktrunk/config.toml;

  # Ensure the wt binary is available on PATH (was previously provided by
  # programs.worktrunk.enable which we no longer use).
  home.packages = [ pkgs.worktrunk ];

  # Worktrunk shell function + WORKTRUNK_BIN injected into zsh initContent.
  # We use mkAfter to ensure this runs after the main initContent from zsh.nix.
  programs.zsh.initContent = lib.mkAfter ''
    source ${worktrunkShellInit}
    export WORKTRUNK_BIN="${wtAuthWrapper}"
  '';
}
