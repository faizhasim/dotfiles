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

in
{
  # Link external TOML config to XDG config directory
  # Using external file (not embedded) for easier editing and version control
  xdg.configFile."worktrunk/config.toml".source = ./worktrunk/config.toml;

  # Ensure the wt binary is available on PATH (was previously provided by
  # programs.worktrunk.enable which we no longer use).
  home.packages = [ pkgs.worktrunk ];

  # Worktrunk shell function + WORKTRUNK_BIN injected into zsh initContent.
  programs.zsh.initContent = lib.mkAfter ''
    source ${worktrunkShellInit}
    export WORKTRUNK_BIN="${pkgs.worktrunk}/bin/wt"
  '';
}
