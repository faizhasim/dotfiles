# gh-dash configuration with manual YAML generation
#
# IMPORTANT: This file uses pkgs.writeText instead of programs.gh-dash.settings
# to avoid automatic line wrapping of long filter strings.
#
# Why manual YAML generation?
# ---------------------------
# Home Manager's programs.gh-dash.settings uses pkgs.formats.yaml { } which:
#   1. Converts Nix attrs → JSON → YAML via remarshal_0_17's json2yaml
#   2. Wraps long strings at ~80 characters by default (ruamel.yaml behavior)
#   3. Does NOT accept parameters to configure line width
#
# Example of problematic wrapping:
#   filters: "is:open sort:created-desc review-requested:@me repo:A repo:B ..."
#   becomes:
#   filters: is:open sort:created-desc review-requested:@me
#     repo:A repo:B ...
#
# This breaks gh-dash filter parsing since it expects filters on a single line.
#
# Technical details:
# - Source: nixpkgs/pkgs/pkgs-lib/formats.nix yaml_1_1 definition
# - Generator: remarshal supports --width inf, but pkgs.formats.yaml doesn't expose it
# - Home Manager module: modules/programs/gh-dash.nix (line 12, 45)
#
# Alternatives considered:
#   1. Custom YAML format with width parameter - too complex for one file
#   2. Submit nixpkgs PR to add width support - long-term solution
#   3. Manual YAML via pkgs.writeText - CURRENT (pragmatic, maintainable)
#
# References:
# - remarshal: https://github.com/remarshal-project/remarshal
# - Home Manager issue: line wrapping breaks filter strings with multiple repos
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  # Define noti repos once - used for both filters and repoPaths
  notiRepos = [
    "SEEK-Jobs/noti-tcp-infra"
    "SEEK-Jobs/noti-experience-resources"
    "SEEK-Jobs/noti-experience-toolbox"
    "SEEK-Jobs/noti-experience-delete-old-resources"
    "SEEK-Jobs/noti-email-templates"
    "SEEK-Jobs/noti-docs"
    "SEEK-Jobs/noti-candidate-preferences-api-automat"
    "SEEK-Jobs/noti-candidate-preferences-ui"
    "SEEK-Jobs/data-migration-notification-preferences-initiator"
    "SEEK-Jobs/noti-candidate-preferences-api"
    "SEEK-Jobs/noti-experience-jobs-hydrator"
    "SEEK-Jobs/noti-mail-cdn"
    "SEEK-Jobs/noti-mailer"
    "SEEK-Jobs/noti-experience-monitoring"
    "SEEK-Jobs/noti-experience-infra"
    "SEEK-Jobs/noti-experience-docs"
    "SEEK-Jobs/noti-experience-hydrators"
    "SEEK-Jobs/noti-base"
    "SEEK-Jobs/ca-profile-onboarding-ui"
    "SEEK-Jobs/ca-settings-ui"
    "SEEK-Jobs/dataplatform-dbt-noti-experience"
  ];

  # Convert repo list to filter format: "repo:A repo:B repo:C"
  notiReposFilter = lib.concatMapStringsSep " " (repo: "repo:${repo}") notiRepos;

  # Generate repoPaths: "SEEK-Jobs/noti-xxx" -> "~/dev/seek-jobs/noti-x/noti-xxx"
  notiRepoPaths = lib.listToAttrs (
    map (repo: {
      name = repo;
      value = "~/dev/seek-jobs/noti-x/${lib.last (lib.splitString "/" repo)}";
    }) notiRepos
  );

  # Combine noti repos with wildcard patterns
  repoPaths = notiRepoPaths // {
    "SEEK-Jobs/*" = "~/dev/seek-jobs/*";
    "faizhasim/*" = "~/dev/faizhasim/*";
  };

  # Generate YAML repoPaths section
  repoPathsYaml = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (repo: path: "      ${repo}: ${path}") repoPaths
  );

  # Generate YAML config with explicit string formatting
  # This ensures filter strings remain on a single line
  configYaml = pkgs.writeText "gh-dash-config.yml" ''
      pager:
        diff: delta

      smartFilteringAtLaunch: true

      repoPaths:
    ${repoPathsYaml}

      keybindings:
        universal:
          - key: g
            name: lazygit
            command: cd {{ .RepoPath }} && lazygit

      prSections:
        - title: "󰳐 author:@me"
          filters: "author:@me is:open archived:false sort:created-desc"

        - title: "󰳐 all requested reviews"
          filters: "is:open sort:created-desc review-requested:@me ${notiReposFilter}"

        - title: "󰳐 mention:@me"
          filters: "is:open mentions:@me sort:created-desc"

        - title: "󰳏 is:open"
          filters: "is:open"

        - title: "󰳐 all reviews"
          filters: "is:open sort:created-desc ${notiReposFilter}"
  '';
in
{
  # Enable gh-dash (installs package and sets up as gh extension)
  programs.gh-dash.enable = true;

  # Override the default config file generation to prevent line wrapping
  # lib.mkForce is required because programs.gh-dash.enable sets this by default
  xdg.configFile."gh-dash/config.yml".source = lib.mkForce configYaml;
}
