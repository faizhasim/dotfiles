#!/usr/bin/env bash
#
# clone-worktrunk-repos.sh
# Idempotent script to clone all repositories for worktrunk workflow
#
# Usage:
#   ./clone-worktrunk-repos.sh
#
# Features:
#   - Idempotent: checks if repo exists with correct remote before cloning
#   - Uses bare clones for worktrunk compatibility
#   - Skips repos with empty remotes (local-only)
#   - Color-coded progress output

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
TOML_FILE="${HOME}/.config/worktrunk/repos.toml"
BASE_DIR="${HOME}/dev"

log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $*"
}

log_warning() {
  echo -e "${YELLOW}[!]${NC} $*"
}

log_error() {
  echo -e "${RED}[✗]${NC} $*"
}

log_step() {
  echo -e "${CYAN}==>${NC} $*"
}

# Check dependencies
check_dependencies() {
  local missing_deps=()
  
  for cmd in yq jq git; do
    if ! command -v "$cmd" &> /dev/null; then
      missing_deps+=("$cmd")
    fi
  done
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_error "Missing required dependencies: ${missing_deps[*]}"
    log_info "Install with: brew install yq jq git"
    exit 1
  fi
}

# Check if TOML file exists
check_toml_file() {
  if [[ ! -f "$TOML_FILE" ]]; then
    log_error "TOML file not found: $TOML_FILE"
    log_info "Run 'edit-worktrunk-repos' to decrypt the file first"
    exit 1
  fi
}

# Get repo name from path
get_repo_name() {
  local path="$1"
  basename "$path"
}

# Check if repo exists with correct remote
repo_exists_with_remote() {
  local repo_dir="$1"
  local expected_remote="$2"
  
  # Check if directory exists
  if [[ ! -d "$repo_dir" ]]; then
    return 1
  fi
  
  # Check if it's a git repository (bare or regular)
  if [[ ! -d "$repo_dir/objects" ]] && [[ ! -d "$repo_dir/.git" ]]; then
    log_warning "Directory exists but is not a git repo: $repo_dir"
    return 1
  fi
  
  # Get current remote URL
  local current_remote
  if [[ -d "$repo_dir/objects" ]]; then
    # Bare repository
    current_remote=$(git -C "$repo_dir" config --get remote.origin.url 2>/dev/null || echo "")
  else
    # Regular repository
    current_remote=$(git -C "$repo_dir" remote get-url origin 2>/dev/null || echo "")
  fi
  
  # Compare remotes
  if [[ "$current_remote" == "$expected_remote" ]]; then
    return 0
  else
    log_warning "Remote mismatch for $(basename "$repo_dir")"
    log_warning "  Expected: $expected_remote"
    log_warning "  Found:    $current_remote"
    return 1
  fi
}

# Clone repository
clone_repo() {
  local repo_path="$1"
  local remote_url="$2"
  local repo_name
  repo_name=$(get_repo_name "$repo_path")
  
  local full_path="${BASE_DIR}/${repo_path}"
  local parent_dir
  parent_dir=$(dirname "$full_path")
  
  # Create parent directory
  if ! mkdir -p "$parent_dir" 2>/dev/null; then
    log_error "Failed to create directory: $parent_dir"
    return 1
  fi
  
  # Clone as bare repository
  log_info "Cloning $repo_name..."
  if git clone --bare "$remote_url" "$full_path" 2>&1 | sed 's/^/  /'; then
    log_success "Cloned: $repo_name"
    return 0
  else
    log_error "Failed to clone: $repo_name"
    return 1
  fi
}

# Process all repos
process_repos() {
  local clone_count=0
  local skip_count=0
  local error_count=0
  local repo_count path remote repo_name repo_data full_path
  
  log_step "Processing repositories from TOML..."
  echo ""
  
  # Get repo count directly from yq
  repo_count=$(yq -p toml eval '.repo | length' "$TOML_FILE" 2>/dev/null)
  
  log_info "Found $repo_count repositories in TOML"
  echo ""
  
  # Use indexed loop to query each repo directly
  for ((i=0; i<repo_count; i++)); do
    # Query both path and remote in one yq call for efficiency
    repo_data=$(yq -p toml -oj eval ".repo[$i] | {\"path\": .path, \"remote\": .remote}" "$TOML_FILE" 2>/dev/null)
    path=$(echo "$repo_data" | jq -r '.path')
    remote=$(echo "$repo_data" | jq -r '.remote')
    repo_name=$(get_repo_name "$path")
    
    # Skip repos with empty remotes (local-only)
    if [[ -z "$remote" || "$remote" == "null" || "$remote" == "" ]]; then
      log_warning "Skipping $repo_name (local-only, no remote)"
      skip_count=$((skip_count + 1))
      continue
    fi
    
    full_path="${BASE_DIR}/${path}"
    
    # Check if repo already exists with correct remote
    if repo_exists_with_remote "$full_path" "$remote"; then
      log_success "Already exists: $repo_name"
      skip_count=$((skip_count + 1))
      continue
    fi
    
    # Clone the repository
    if clone_repo "$path" "$remote"; then
      clone_count=$((clone_count + 1))
    else
      error_count=$((error_count + 1))
    fi
    
    echo ""
    
  done
  
  # Summary
  log_step "Clone Summary"
  echo "  Total processed: $((clone_count + skip_count + error_count))"
  echo "  Newly cloned:    $clone_count"
  echo "  Already existed: $skip_count"
  echo "  Errors:          $error_count"
  
  if [[ $error_count -gt 0 ]]; then
    log_warning "Some repositories failed to clone. Check output above for details."
    return 1
  else
    log_success "All repositories are ready!"
    return 0
  fi
}

# Main
main() {
  log_step "Worktrunk Repository Clone Script"
  echo ""
  
  check_dependencies
  check_toml_file
  
  if process_repos; then
    echo ""
    log_info "Setup complete! Your worktrunk environment is ready."
    log_info "Use 'git worktree' commands to create working directories."
  else
    echo ""
    log_error "Setup incomplete due to errors."
    exit 1
  fi
}

main
