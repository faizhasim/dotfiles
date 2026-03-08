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
    "SEEK-Jobs/noti-platform"
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

  # Generate repoPaths with worktrunk structure
  # Pattern: ~/dev/seek-jobs/customer-notification-system/<repo-name>/
  # This points to the main worktree (actual branch name determined by worktrunk)
  notiRepoPaths = lib.listToAttrs (
    map (repo: {
      name = repo;
      value = "~/dev/seek-jobs/customer-notification-system/${lib.last (lib.splitString "/" repo)}";
    }) notiRepos
  );

  # Additional system repos
  systemRepoPaths = {
    "SEEK-Jobs/owners" = "~/dev/seek-jobs/owners/owners";
    "SEEK-Jobs/owners-metrics-publisher" = "~/dev/seek-jobs/owners/owners-metrics-publisher";
    "SEEK-Jobs/seek-backstage" = "~/dev/seek-jobs/seek-backstage/seek-backstage";
    "SEEK-Jobs/build-agency" = "~/dev/seek-jobs/build-agency/build-agency";
    "SEEK-Jobs/build-agency-strategies" = "~/dev/seek-jobs/build-agency/build-agency-strategies";
  };

  # Combine all repos with wildcard patterns
  repoPaths =
    notiRepoPaths
    // systemRepoPaths
    // {
      "SEEK-Jobs/*" = "~/dev/seek-jobs/misc/*";
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

        prs:
          - key: m
            name: quick merge (squash)
            command: gh pr merge --squash --auto --repo {{ .RepoName }} {{ .PrNumber }}

          - key: x
            name: request changes
            command: >
              gh pr review --repo {{ .RepoName }} --request-changes
              --body "$(gum input --prompt='What needs changing: ')"
              {{ .PrNumber }}

          - key: z
            name: open in zellij
            command: >
              REPO_PATH="{{ .RepoPath }}" &&
              REPO_PATH="''${REPO_PATH/#\~/$HOME}" &&
              PR_NUMBER="{{ .PrNumber }}" &&
              REPO_NAME="{{ .RepoName }}" &&
              SESSION_NAME=$(echo "''$REPO_NAME" | tr '/' '-') &&
              cd "''$REPO_PATH" &&
              if [ -n "''$ZELLIJ" ]; then
                WT_OUTPUT=$(yes n | wt switch "pr:''$PR_NUMBER" 2>&1) &&
                echo "''$WT_OUTPUT" | grep -v "Install shell integration" | head -n 5 &&
                NEW_PATH=$(echo "''$WT_OUTPUT" | grep "@ ~" | sed -n 's/.*@ \([^,]*\).*/\1/p' | sed "s|~|''$HOME|" | tail -1) &&
                if [ -n "''$NEW_PATH" ] && [ -d "''$NEW_PATH" ]; then
                  zellij action new-tab --cwd "''$NEW_PATH" --name "PR ''$PR_NUMBER" || exit 1 &&
                  sleep 0.2 &&
                  zellij action write-chars "cd \"''$NEW_PATH\" && clear && pwd && ''${EDITOR:-nvim} ." &&
                  zellij action write 13
                else
                  echo "Failed to get worktree path: NEW_PATH=''$NEW_PATH"
                fi
              else
                WT_OUTPUT=$(timeout 30 sh -c 'yes n | wt switch "pr:'"''$PR_NUMBER"'" 2>&1') &&
                NEW_PATH=$(echo "''$WT_OUTPUT" | grep "@ ~" | sed -n 's/.*@ \([^,]*\).*/\1/p' | sed "s|~|''$HOME|" | tail -1) &&
                if [ -n "''$NEW_PATH" ] && [ -d "''$NEW_PATH" ]; then
                  cd "''$NEW_PATH" &&
                  ''${EDITOR:-nvim} .
                else
                  echo "ERROR: Failed to get worktree path: NEW_PATH=''$NEW_PATH"
                  exit 1
                fi
              fi

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
