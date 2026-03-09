#!/usr/bin/env bash
# Generate gh-dash config using gomplate templating
# Clean separation: template defines structure, data file provides values

set -euo pipefail

TEMPLATE_PATH="${1:?Template path required}"
USER_HOME="${2:-$HOME}"
REPOS_TOML="$USER_HOME/.config/worktrunk/repos.toml"
CONFIG_YML="$USER_HOME/.config/gh-dash/config.yml"
DATA_FILE="/tmp/gh-dash-data.$$.json"

mkdir -p "$(dirname "$CONFIG_YML")"

# Check if repos.toml exists - fail fast if not
if [[ ! -f "$REPOS_TOML" ]]; then
  echo "ERROR: $REPOS_TOML not found!" >&2
  echo "" >&2
  echo "Expected repos.toml structure:" >&2
  cat <<'EOF' >&2
[[repo]]
path = "myorg/my-system/repo1"
remote = "git@github.com:MyOrg/repo1.git"
gh_dash_filter = true

[[repo]]
path = "myorg/my-system/repo2"
remote = "git@github.com:MyOrg/repo2.git"
gh_dash_filter = false

[wildcards]
patterns = [
  { org = "MyOrg", path = "~/dev/myorg/misc/*" },
  { org = "faizhasim", path = "~/dev/faizhasim/*" },
]
EOF
  echo "" >&2
  echo "Example data that would be generated:" >&2
  cat <<'EOF'
{
  "repoPaths": {
    "MyOrg/repo1": "~/dev/myorg/my-system/repo1",
    "MyOrg/repo2": "~/dev/myorg/my-system/repo2",
    "MyOrg/*": "~/dev/myorg/misc/*",
    "faizhasim/*": "~/dev/faizhasim/*"
  },
  "reposFilter": "repo:MyOrg/repo1"
}
EOF
  exit 1
fi

# Build data file for gomplate
{
  # Extract repoPaths: ALL repos (regardless of gh_dash_filter) + wildcards
  REPO_PATHS_JSON=$(
    {
      # Extract all repos from [[repo]] entries
      yq eval -o=json '.repo[]' "$REPOS_TOML" | \
        jq -s 'map(
          .path as $path | 
          .remote as $remote |
          if $remote != "" then
            # Extract org/repo from git URL (e.g., git@github.com:SEEK-Jobs/repo.git -> SEEK-Jobs/repo)
            ($remote | capture("github\\.com:(?<org>[^/]+)/(?<repo>[^.]+)") | "\(.org)/\(.repo)") as $full_name |
            {($full_name): "~/dev/\($path)"}
          else
            # Skip repos with empty remotes (local-only)
            empty
          end
        ) | add // {}'
      
      # Add wildcard patterns
      yq eval -o=json '.wildcards.patterns[]?' "$REPOS_TOML" | \
        jq -s 'map({("\(.org)/*"): .path}) | add // {}'
    } | jq -s 'add'
  )

  # Build repo filter string: ONLY repos with gh_dash_filter=true
  REPOS_FILTER=$(yq eval -o=json '.repo[]' "$REPOS_TOML" | \
    jq -sr 'map(
      select(.gh_dash_filter == true) |
      .remote as $remote |
      if $remote != "" then
        # Extract org/repo from git URL
        ($remote | capture("github\\.com:(?<org>[^/]+)/(?<repo>[^.]+)") | "repo:\(.org)/\(.repo)")
      else
        empty
      end
    ) | join(" ")')

  # Create data file
  jq -n \
    --argjson repoPaths "$REPO_PATHS_JSON" \
    --arg reposFilter "$REPOS_FILTER" \
    '{
      repoPaths: $repoPaths,
      reposFilter: $reposFilter
    }' > "$DATA_FILE"
}

# Use gomplate to render template with data
# Note: using stdout redirect instead of -o flag due to gomplate path handling issues
gomplate -d data="$DATA_FILE" -f "$TEMPLATE_PATH" > "$CONFIG_YML"

# Cleanup
rm -f "$DATA_FILE"

echo "Generated gh-dash config at $CONFIG_YML"
