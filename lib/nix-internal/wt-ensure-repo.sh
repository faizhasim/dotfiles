#!/usr/bin/env bash
#
# wt-ensure-repo.sh
# Lazy clone wrapper for worktrunk workflow
# Ensures repo exists (bare clone) before switching to PR worktree
#
# Usage:
#   wt-ensure-repo.sh <repo_name> <pr_number> [repo_path]
#
# Example:
#   wt-ensure-repo.sh "seek-jobs/noti-mailer" "123" "seek-jobs/customer-notification-system/noti-mailer"
#
# Returns:
#   Prints the worktree path on success (for gh-dash to use)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
TOML_FILE="${HOME}/.config/worktrunk/repos.toml"
BASE_DIR="${HOME}/dev"
FALLBACK_ORG="misc"

log_info() {
  echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $*" >&2
}

log_warning() {
  echo -e "${YELLOW}[!]${NC} $*" >&2
}

log_error() {
  echo -e "${RED}[✗]${NC} $*" >&2
}

# Get repo info from repos.toml
# Supports both [[repo]] format and [[systems]] format
# Returns: {"path": "...", "remote": "..."} or empty if not found
get_repo_info_from_toml() {
  local repo_name="$1"
  local repo_count repo_data

  if [[ ! -f "$TOML_FILE" ]]; then
    return 1
  fi

  # Try [[repo]] format first
  repo_count=$(yq -p toml eval '.repo | length' "$TOML_FILE" 2>/dev/null) || repo_count=0

  if [[ "${repo_count:-0}" -gt 0 ]]; then
    # Search in [[repo]] entries
    local i
    for ((i=0; i<repo_count; i++)); do
      repo_data=$(yq -p toml -oj eval ".repo[$i] | {\"path\": .path, \"remote\": .remote}" "$TOML_FILE" 2>/dev/null) || continue
      local remote full_name
      remote=$(echo "$repo_data" | jq -r '.remote // empty' 2>/dev/null) || continue

      # Extract org/repo from remote URL
      if [[ -n "$remote" ]]; then
        full_name=$(echo "$remote" | sed -n 's/.*github\.com:\([^/]*\)\/\([^\.]*\).*/\1\/\2/p')
        if [[ "$full_name" == "$repo_name" ]]; then
          echo "$repo_data"
          return 0
        fi
      fi
    done
  fi

  return 1
}

# Get wildcard patterns from repos.toml for fallback
get_wildcard_path() {
  local org="$1"
  yq -p toml eval ".wildcards.patterns[] | select(.org == \"$org\") | .path" "$TOML_FILE" 2>/dev/null | head -1
}

# Check if a directory is a git repo (bare or regular)
is_git_repo() {
  local dir="$1"
  [[ -d "$dir/objects" ]] || [[ -d "$dir/.git" ]]
}

# Get remote URL from existing repo
get_existing_remote() {
  local dir="$1"
  if [[ -d "$dir/objects" ]]; then
    # Bare repo
    git -C "$dir" config --get remote.origin.url 2>/dev/null || echo ""
  elif [[ -d "$dir/.git" ]]; then
    # Regular repo
    git -C "$dir" remote get-url origin 2>/dev/null || echo ""
  else
    echo ""
  fi
}

# Clone a repo as bare
clone_bare_repo() {
  local remote_url="$1"
  local target_path="$2"
  local repo_name
  repo_name=$(basename "$target_path")

  local parent_dir
  parent_dir=$(dirname "$target_path")

  log_info "Creating parent directory: $parent_dir"
  mkdir -p "$parent_dir"

  log_info "Bare cloning $repo_name..."
  if git clone --bare "$remote_url" "$target_path" 2>&1 | sed 's/^/  /' >&2; then
    log_success "Bare cloned: $repo_name"
    return 0
  else
    log_error "Failed to clone: $repo_name"
    return 1
  fi
}

# Prefix each line of output with indentation
indent_output() {
  while IFS= read -r line; do
    echo "  $line"
  done
}

# Extract worktree path from wt switch output
# Works even when wt returns non-zero exit code (due to auto-cd failure)
extract_worktree_path() {
  local wt_output="$1"
  local repo_path="$2"

  # Look for "@ ~/dev/..." pattern - stop at comma or whitespace
  local worktree_path
  worktree_path=$(echo "$wt_output" | grep -oE '@ ~/[^[:space:],]+' | sed 's/^@ //' | tail -1)

  if [[ -n "$worktree_path" ]]; then
    echo "$worktree_path"
    return 0
  fi

  # Alternative: look for worktree path in the PR branch name format
  # The path appears before ", but cannot change directory"
  worktree_path=$(echo "$wt_output" | grep -oE "${repo_path}\.[^[:space:],]+" | tail -1)

  if [[ -n "$worktree_path" ]]; then
    echo "$worktree_path"
    return 0
  fi

  return 1
}

# Main logic
main() {
  if [[ $# -lt 2 ]]; then
    log_error "Usage: $0 <repo_name> <pr_number> [repo_path]"
    exit 1
  fi

  local repo_name="$1"
  local pr_number="$2"

  local org repo_short
  org=$(echo "$repo_name" | cut -d'/' -f1)
  repo_short=$(echo "$repo_name" | cut -d'/' -f2)

  log_info "Processing: $repo_name (PR #$pr_number)"

  # Try to get repo info from repos.toml
  local repo_info remote_url target_path
  repo_info=$(get_repo_info_from_toml "$repo_name") || repo_info=""

  if [[ -n "$repo_info" ]]; then
    # Found in repos.toml
    local toml_path
    toml_path=$(echo "$repo_info" | jq -r '.path')
    remote_url=$(echo "$repo_info" | jq -r '.remote')
    target_path="${BASE_DIR}/${toml_path}"
    log_info "Found in repos.toml: $toml_path"
  else
    # Not in repos.toml - use fallback
    log_warning "Repo not in repos.toml, using fallback location"

    # Try to find wildcard pattern for this org
    local wildcard_path
    wildcard_path=$(get_wildcard_path "$org" || echo "")

    if [[ -n "$wildcard_path" ]]; then
      # Use wildcard pattern, replacing * with repo name
      target_path="${wildcard_path/\*/$repo_short}"
      # Expand ~ to $HOME
      target_path="${target_path/#\~/$HOME}"
    else
      # Use generic fallback
      target_path="${BASE_DIR}/${FALLBACK_ORG}/${repo_short}"
    fi

    # Construct remote URL from repo name
    remote_url="git@github.com:${repo_name}.git"
    log_info "Fallback location: $target_path"
  fi

  # Check if repo already exists (bare or regular)
  if is_git_repo "$target_path"; then
    local existing_remote
    existing_remote=$(get_existing_remote "$target_path")
    log_info "Repo exists at $target_path"
    log_info "Remote: $existing_remote"

    # Verify remote matches (if we have an expected remote)
    if [[ -n "$remote_url" && "$existing_remote" != "$remote_url" ]]; then
      log_warning "Remote mismatch!"
      log_warning "  Expected: $remote_url"
      log_warning "  Found:    $existing_remote"
      log_warning "Using existing repo anyway..."
    fi
  else
    # Repo doesn't exist - need to clone
    if [[ -z "$remote_url" ]]; then
      log_error "Cannot clone: no remote URL available"
      exit 1
    fi

    log_info "Repo not found, cloning..."
    if ! clone_bare_repo "$remote_url" "$target_path"; then
      log_error "Failed to clone repository"
      exit 1
    fi
  fi

  # Now switch to the PR worktree
  log_info "Switching to worktree for PR #$pr_number..."

  # Change to the repo directory (required for wt to work)
  cd "$target_path" || {
    log_error "Failed to cd to $target_path"
    exit 1
  }

  local wt_output new_path
  # Run wt switch and capture output
  # Use 'yes n' to answer 'n' to any prompts (like shell integration install)
  # Note: wt may return non-zero due to auto-cd failure, but worktree is still created
  wt_output=$(yes n | wt switch "pr:${pr_number}" 2>&1) || true

  # Log the output for debugging
  echo "$wt_output" | indent_output >&2

  # Extract worktree path from output (works even if wt returned non-zero)
  new_path=$(extract_worktree_path "$wt_output" "$target_path")

  # If we couldn't extract the path, check for actual errors in output
  if [[ -z "$new_path" ]]; then
    # Check for actual error indicators
    if echo "$wt_output" | grep -qE "(✗|error|Error|failed|Failed)"; then
      log_error "wt switch failed with errors"
      exit 1
    fi

    # Check if worktree was actually created despite exit code
    # The worktree path follows pattern: repo_path.branch-name
    local potential_worktree
    potential_worktree=$(find "$(dirname "$target_path")" -maxdepth 1 -name "$(basename "$target_path").*" -type d 2>/dev/null | sort -t. -k2 -r | head -1)

    if [[ -n "$potential_worktree" && -d "$potential_worktree" ]]; then
      new_path="$potential_worktree"
      log_info "Found worktree at: $new_path"
    else
      log_error "Failed to extract worktree path from wt output"
      exit 1
    fi
  fi

  # Expand ~ in path if present
  new_path="${new_path/#\~/$HOME}"

  if [[ ! -d "$new_path" ]]; then
    log_error "Worktree path does not exist: $new_path"
    exit 1
  fi

  log_success "Worktree ready: $new_path"

  # Print the path for the caller to use
  echo "$new_path"
}

main "$@"
