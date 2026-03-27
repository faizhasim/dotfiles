# gh-dash configuration with runtime config generation from encrypted worktrunk catalog
#
# Architecture:
# ------------
# 1. Encrypted worktrunk catalog: secrets/worktrunk-repos.toml.age (committed to git)
# 2. At system activation:
#    a. agenix decrypts → ~/.config/worktrunk/repos.toml
#    b. scripts/generate-gh-dash-config.sh reads repos.toml → generates config.yml
# 3. gh-dash reads config.yml at runtime
#
# Why this approach?
# -----------------
# - Nix evaluation happens BEFORE agenix decryption
# - Can't use lib.importTOML on encrypted files at build time
# - Solution: Generate config at activation time (after decryption)
#
# Workflow:
# --------
# 1. Edit repos: ./scripts/edit-worktrunk-repos.sh (or agenix -e secrets/worktrunk-repos.toml.age)
# 2. Rebuild: darwin-rebuild switch --flake .#M3419
# 3. Config auto-generates during activation
# 4. No manual file updates needed
#
# Catalog example: config/worktrunk/repos.toml.example
# Generator: scripts/generate-gh-dash-config.sh
# Encryption config: darwin/secrets.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Package the wt-ensure-repo script for use by gh-dash
  # Note: Using yq-go (mikefarah/yq Go version) instead of yq (python-yq)
  # because they have different CLI syntax
  wt-ensure-repo = pkgs.writeShellApplication {
    name = "wt-ensure-repo";
    runtimeInputs = with pkgs; [
      git
      yq-go
      jq
      worktrunk
    ];
    text = builtins.readFile ../scripts/wt-ensure-repo.sh;
  };
in
{
  # Enable gh-dash (installs package and sets up as gh extension)
  programs.gh-dash.enable = true;

  # Install the wt-ensure-repo helper script
  home.packages = [ wt-ensure-repo ];

  # Don't generate config file - it's generated at activation time by the script
  # The script runs after agenix decrypts repos.toml and creates config.yml
  xdg.configFile."gh-dash/config.yml".enable = false;
}
