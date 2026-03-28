#!/usr/bin/env bash
# Generate zellij config using gomplate templating
# Dynamically populates root_dirs from repos.toml

set -euo pipefail

TEMPLATE_PATH="${1:?Template path required}"
USER_HOME="${2:-$HOME}"
REPOS_TOML="${REPOS_TOML:-$USER_HOME/.config/worktrunk/repos.toml}"
ZELLIJ_CONFIG="$USER_HOME/.config/zellij/config.kdl"
DATA_FILE="/tmp/zellij-data.$$.json"

mkdir -p "$(dirname "$ZELLIJ_CONFIG")"

# Check if repos.toml exists - fail fast if not
if [[ ! -f "$REPOS_TOML" ]]; then
  echo "ERROR: $REPOS_TOML not found!" >&2
  echo "" >&2
  echo "repos.toml should be available at ~/.config/worktrunk/repos.toml" >&2
  echo "This file is typically decrypted from agenix secrets during system activation." >&2
  exit 1
fi

# Build root_dirs from repos.toml
# Extract parent directories of repos (systems), not individual repos
# e.g., "seek-jobs/system/repo" -> "~/dev/seek-jobs/system"
build_root_dirs() {
  local repo_paths=()

  # Extract parent directories from [[repo]] entries
  # repos.toml format: path = "seek-jobs/system/repo-name"
  # We extract the system directory (one level up from repo)
  while IFS= read -r path; do
    if [[ -n "$path" ]]; then
      # Get parent directory (system level)
      # e.g., "seek-jobs/tcp-tiny-carrier-pigeons-v2/noti-mailer" -> "seek-jobs/tcp-tiny-carrier-pigeons-v2"
      local system_dir
      system_dir=$(dirname "$path")
      repo_paths+=("$USER_HOME/dev/$system_dir")
    fi
  done < <(yq -p toml eval '.repo[].path' "$REPOS_TOML" 2>/dev/null || true)

  # Extract wildcard patterns, stripping the /* suffix
  # Format: { org = "...", path = "~/dev/org/*" } -> ~/dev/org
  while IFS= read -r wildcard_path; do
    [[ -n "$wildcard_path" ]] && repo_paths+=("${wildcard_path%/\*}")
  done < <(yq -p toml eval '.wildcards.patterns[].path' "$REPOS_TOML" 2>/dev/null | sed 's/\*$//' || true)

  # Deduplicate and sort
  if [[ ${#repo_paths[@]} -gt 0 ]]; then
    printf '%s\n' "${repo_paths[@]}" | sort -u | paste -sd ';' -
  else
    echo ""
  fi
}

# Build the root_dirs string
ROOT_DIRS=$(build_root_dirs)

# Create data file for gomplate
jq -n \
  --arg rootDirs "$ROOT_DIRS" \
  '{
    rootDirs: $rootDirs
  }' > "$DATA_FILE"

# Use gomplate to render template with data
gomplate -d data="$DATA_FILE" -f "$TEMPLATE_PATH" > "$ZELLIJ_CONFIG"

# Cleanup
rm -f "$DATA_FILE"

echo "Generated zellij config at $ZELLIJ_CONFIG"
echo "  - Root dirs: $(echo "$ROOT_DIRS" | tr ';' '\n' | wc -l) paths configured"
