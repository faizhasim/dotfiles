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
[[systems]]
name = "my-system"
org = "MyOrg"
path = "myorg/my-system"
repos = ["repo1", "repo2"]

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
  "reposFilter": "repo:MyOrg/repo1 repo:MyOrg/repo2"
}
EOF
  exit 1
fi

# Build data file for gomplate
{
  # Extract repoPaths: combine system repos + wildcards
  REPO_PATHS_JSON=$(
    {
      yq eval -o=json '.systems[]' "$REPOS_TOML" | \
        jq -s 'map(.org as $org | .path as $path | .repos[] | {("\($org)/\(.)"): "~/dev/\($path)/\(.)"}) | add // {}'
      yq eval -o=json '.wildcards.patterns[]?' "$REPOS_TOML" | \
        jq -s 'map({("\(.org)/*"): .path}) | add // {}'
    } | jq -s 'add'
  )

  # Build repo filter string
  REPOS_FILTER=$(yq eval -o=json '.systems[]' "$REPOS_TOML" | \
    jq -sr 'map(.org as $org | .repos[] | "repo:\($org)/\(.)") | join(" ")')

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
gomplate -d data="$DATA_FILE" -f "$TEMPLATE_PATH" -o "$CONFIG_YML"

# Cleanup
rm -f "$DATA_FILE"

echo "Generated gh-dash config at $CONFIG_YML"
