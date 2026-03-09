#!/usr/bin/env bash
#
# migrate-worktrunk-repos.sh
# Migrate repositories from current locations to target worktrunk structure

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
TOML_FILE="${HOME}/.config/worktrunk/repos.toml"
ROLLBACK_FILE="${HOME}/.config/worktrunk/migration-rollback.sh"
BASE_DIR="${HOME}/dev"

MODE="${1:-help}"

usage() {
  echo "Usage: $0 {dry-run|execute|rollback}"
  exit 1
}

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[✓]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $*"; }
log_error() { echo -e "${RED}[✗]${NC} $*"; }
log_step() { echo -e "${CYAN}==>${NC} $*"; }

check_dependencies() {
  for cmd in yq jq; do
    if ! command -v "$cmd" &> /dev/null; then
      log_error "Missing: $cmd"
      exit 1
    fi
  done
}

perform_migration() {
  local dry_run="$1"
  local move_count=0
  local skip_count=0
  local repo_count path remote repo_name current target repo_data target_parent
  
  if [[ "$dry_run" == "false" ]]; then
    cat > "$ROLLBACK_FILE" << 'EOFROLL'
#!/usr/bin/env bash
set -euo pipefail
GREEN='\033[0;32m'
NC='\033[0m'
echo "Starting rollback..."
EOFROLL
    chmod +x "$ROLLBACK_FILE"
  fi
  
  log_step "Analyzing repository locations..."
  echo ""
  
  # Get repo count directly from yq
  repo_count=$(yq -p toml eval '.repo | length' "$TOML_FILE" 2>/dev/null)
  
  log_info "Found $repo_count repos in TOML"
  echo ""
  
  # Use indexed loop to query each repo directly
  for ((i=0; i<repo_count; i++)); do
    # Query both path and remote in one yq call for efficiency
    repo_data=$(yq -p toml -oj eval ".repo[$i] | {\"path\": .path, \"remote\": .remote}" "$TOML_FILE" 2>/dev/null)
    path=$(echo "$repo_data" | jq -r '.path')
    remote=$(echo "$repo_data" | jq -r '.remote')
    repo_name=$(basename "$path")
    
    # Skip local-only repos
    if [[ -z "$remote" || "$remote" == "null" || "$remote" == "" ]]; then
      log_warning "Skip $repo_name (local-only)"
      skip_count=$((skip_count + 1))
      continue
    fi
    
    # Find current location
    current=$(find "$BASE_DIR/seek-jobs" -type d -name "$repo_name" -maxdepth 3 2>/dev/null | head -1 || echo "")
    
    if [[ -z "$current" ]]; then
      log_warning "Skip $repo_name (not found, will clone fresh)"
      skip_count=$((skip_count + 1))
      continue
    fi
    
    # Check if move needed
    target="$BASE_DIR/$path"
    current=$(cd "$current" && pwd)
    
    if [[ "$current" == "$target" ]]; then
      log_success "OK $repo_name (already in place)"
      skip_count=$((skip_count + 1))
      continue
    fi
    
    # Move needed
    log_info "Move: $repo_name"
    echo "      FROM: $current"
    echo "      TO:   $target"
    echo ""
    
    if [[ "$dry_run" == "false" ]]; then
      target_parent=$(dirname "$target")
      
      if mkdir -p "$target_parent" && mv "$current" "$target"; then
        log_success "Moved: $repo_name"
        move_count=$((move_count + 1))
        
        # Add rollback
        cat >> "$ROLLBACK_FILE" << EOFROLL2
mkdir -p "$(dirname "$current")"
mv "$target" "$current"
echo -e "\${GREEN}[✓]\${NC} Restored: $repo_name"
EOFROLL2
      else
        log_error "Failed: $repo_name"
      fi
    else
      move_count=$((move_count + 1))
    fi
  done
  
  # Cleanup empty dirs
  if [[ "$dry_run" == "false" ]]; then
    echo ""
    log_step "Cleaning up..."
    for dir in "$BASE_DIR/seek-jobs/customer-notification-system" \
               "$BASE_DIR/seek-jobs/build-agency" \
               "$BASE_DIR/seek-jobs/noti-x"; do
      if [[ -d "$dir" ]] && [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
        rmdir "$dir" 2>/dev/null && log_success "Removed: $(basename "$dir")" || true
      fi
    done
  fi
  
  echo ""
  log_step "Summary"
  echo "  Will move: $move_count"
  echo "  Skipped:   $skip_count"
  
  if [[ "$dry_run" == "false" ]]; then
    echo ""
    log_success "Migration complete!"
    log_info "Rollback: $ROLLBACK_FILE"
  else
    echo ""
    log_info "Dry run complete. Use 'execute' to perform migration."
  fi
}

perform_rollback() {
  if [[ ! -f "$ROLLBACK_FILE" ]]; then
    log_error "No rollback file found"
    exit 1
  fi
  
  log_warning "This will undo the migration."
  read -p "Continue? (y/N) " -n 1 -r
  echo
  
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cancelled"
    exit 0
  fi
  
  log_step "Rolling back..."
  bash "$ROLLBACK_FILE"
  log_success "Rollback complete!"
}

main() {
  case "$MODE" in
    dry-run)
      log_step "Migration DRY-RUN"
      echo ""
      check_dependencies
      perform_migration "true"
      ;;
    execute)
      log_step "Migration EXECUTE"
      echo ""
      check_dependencies
      perform_migration "false"
      ;;
    rollback)
      perform_rollback
      ;;
    *)
      log_error "Unknown mode: $MODE"
      usage
      ;;
  esac
}

main
