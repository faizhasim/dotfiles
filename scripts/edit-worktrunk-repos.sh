#!/usr/bin/env bash
# Helper script to edit encrypted worktrunk repos catalog
# This catalog is used to generate configs for multiple tools (gh-dash, etc.)
# Usage: ./scripts/edit-worktrunk-repos.sh

set -euo pipefail

# Color definitions
readonly RESET='\033[0m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'

# Bold colors
readonly BOLD_GREEN='\033[1;32m'
readonly BOLD_BLUE='\033[1;34m'
readonly BOLD_YELLOW='\033[1;33m'
readonly BOLD_CYAN='\033[1;36m'

# Icons
readonly ICON_LOCK="🔐"
readonly ICON_EDIT="📝"
readonly ICON_SUCCESS="✅"
readonly ICON_ARROW="→"
readonly ICON_INFO="ℹ️"
readonly ICON_WARNING="⚠️"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENCRYPTED_FILE="secrets/worktrunk-repos.toml.age"

# Helper functions
print_header() {
  echo -e "\n${BOLD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${BOLD_CYAN}${ICON_LOCK}  Worktrunk Repository Catalog Editor${RESET}"
  echo -e "${BOLD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

print_info() {
  echo -e "${CYAN}${ICON_INFO}  ${1}${RESET}"
}

print_success() {
  echo -e "${BOLD_GREEN}${ICON_SUCCESS}  ${1}${RESET}"
}

print_warning() {
  echo -e "${BOLD_YELLOW}${ICON_WARNING}  ${1}${RESET}"
}

print_error() {
  echo -e "${RED}✗ ${1}${RESET}" >&2
}

print_step() {
  echo -e "${MAGENTA}▸${RESET} ${1}"
}

print_path() {
  echo -e "  ${DIM}${1}${RESET}"
}

# Main script
print_header

print_info "Encrypted file location:"
print_path "$REPO_ROOT/$ENCRYPTED_FILE"
echo ""

print_info "This catalog is used by:"
print_step "gh-dash config generation"
print_step "automated clone scripts ${DIM}(future)${RESET}"
print_step "worktrunk tooling ${DIM}(future)${RESET}"
echo ""

# Check for agenix key
cd "$REPO_ROOT"

if [ ! -f ~/.ssh/agenix-key ]; then
  print_warning "Agenix decryption key not found"
  print_step "Extracting from 1Password..."

  if op document get "agenix-decryption-key" --vault Private >~/.ssh/agenix-key 2>/dev/null; then
    chmod 600 ~/.ssh/agenix-key
    print_success "Key extracted successfully"
  else
    print_error "Failed to extract key from 1Password"
    echo -e "\n${DIM}Make sure you're authenticated:${RESET}"
    echo -e "  ${CYAN}eval \$(op signin)${RESET}\n"
    exit 1
  fi
  echo ""
fi

# Edit the file
print_info "Opening editor..."
echo ""

if agenix -i ~/.ssh/agenix-key -e "$ENCRYPTED_FILE"; then
  echo ""
  print_success "File saved and re-encrypted!"
  echo ""

  echo -e "${BOLD}Next steps:${RESET}"
  echo -e "  ${BOLD_CYAN}1.${RESET} Apply configuration:  ${CYAN}sudo darwin-rebuild switch --flake .#M3419${RESET}"
  echo -e "  ${BOLD_CYAN}2.${RESET} Decrypts to:          ${DIM}~/.config/worktrunk/repos.toml${RESET}"
  echo -e "  ${BOLD_CYAN}3.${RESET} Generates config:     ${DIM}~/.config/gh-dash/config.yml${RESET}"
  echo ""
else
  print_error "Failed to edit file"
  exit 1
fi
