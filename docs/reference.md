# Reference

This document contains important gotchas, limitations, and design decisions you should know about when using or forking this configuration.

## Important Design Decisions

### AeroSpace Raw TOML Configuration

**Why:** AeroSpace configuration is stored as a raw TOML file (`home-manager/aerospace/aerospace.toml`) instead of being generated from Nix.

**Reason:** Nix's TOML generation has issues with formatting that doesn't work well with AeroSpace's parser.

**Impact:**
- Changes to AeroSpace config require editing the raw TOML file
- Benefit: Direct control over configuration
- Drawback: Not fully declarative like other configs

### Zellij Configuration Approach

**Why:** Zellij uses a hybrid approach with both raw KDL and Nix-generated configs.

**Structure:**
- `home-manager/zellij/config.kdl` - Raw KDL for keybindings and general settings
- `home-manager/zellij.nix` - Nix-generated layouts with Stylix color integration

**Reason:** KDL syntax is simpler for keybindings, but layouts benefit from Nix's Nord theme integration via Stylix.

**Impact:**
- Keybindings: Edit `config.kdl` directly
- Status bar styling: Automatically themed via Nix
- Plugins: Managed via Nix fetchurl for version control

### gh-dash Manual YAML Configuration

**Why:** gh-dash config uses manual YAML generation (`pkgs.writeText`) instead of `programs.gh-dash.settings`.

**Reason:** Home Manager's YAML generator wraps long lines at ~80 characters, breaking GitHub filter strings.

**Example Problem:**
```yaml
# What we want:
filters: "is:open review-requested:@me repo:A repo:B repo:C"

# What nix-darwin generates (broken):
filters: is:open review-requested:@me repo:A
  repo:B repo:C
```

**Impact:**
- Filter strings must remain on single lines
- Manual YAML ensures correct formatting
- Trade-off: Less type-safe but functionally correct

**Reference:** See detailed comment in `home-manager/gh-dash.nix` lines 1-33.

**Why:** Homebrew must be installed manually before running nix-darwin.

**Reason:** The `nix-homebrew` flake input manages taps as flake inputs, making it difficult to handle private taps from private GitHub repositories without exposing authentication tokens.

**Workaround:**
1. Install Homebrew manually: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
2. Let nix-darwin manage packages via `homebrew.*` options
3. nix-darwin will use the existing Homebrew installation

> [!NOTE]
> This is a pragmatic compromise between full declarative management and practical usability with private repositories.

### Neovim Outside Nix

**Why:** Neovim configuration is managed via GNU Stow and LazyVim instead of through Nix/home-manager.

**Reasons:**
1. **Direct configuration management** - Need to modify `~/.config/nvim` directly for productivity
2. **Mason compatibility** - Mason package manager for LSPs and tools works with traditional config structure
3. **Faster iteration** - No rebuild needed for plugin changes
4. **LazyVim ecosystem** - Better integration with LazyVim's update mechanisms and community patterns

**Impact:**
- Neovim setup requires running `scripts/setup-nvim.sh` after initial system build
- Plugin updates happen independently via `:Lazy sync`
- Configuration is still version-controlled, just not Nix-managed

**Trade-off:** Direct file access and Mason support vs. complete Nix-managed approach.

### dnsmasq Port Configuration

**Why:** dnsmasq runs on port 53535 instead of standard port 53.

**Reason:** 
- macOS uses mDNSResponder on port 53
- Port 5353 is reserved for multicast DNS
- Port 53535 avoids conflicts while being high enough to not require root

**Impact:**
- Requires macOS resolver configuration in `/etc/resolver/`
- Uses direnv `use dns` function for automatic setup
- Works seamlessly with `scutil --dns` macOS DNS resolution

**Configuration:**
```bash
# /etc/resolver/dev.seek.com.au
nameserver 127.0.0.1
port 53535
```

### neotest "Force Exiting Jest" False Failures

**Issue:** Tests pass but neotest shows them as FAILED with "Force exiting Jest" warning.

**Cause:** Jest exits before neotest's JSON output file is fully written to disk.

**Impact:**
- Visual status indicators are incorrect
- Test output is still available and accurate
- Tests actually passed despite FAILED status

**Workaround:**
- Check terminal output instead of relying on status icons
- neotest is still valuable for running tests from Neovim
- See [neotest.md](./neotest.md) for details

**Status:** Known limitation, no current fix.

### ice-bar vs Alternatives

**Current:** ice-bar is used for hiding menu bar items.

**Why ice-bar:**
- Nix package available
- Simple, does the job
- Declaratively configured

**Alternatives:**
Any menu bar hiding app works equally well:
- **HiddenBar** - Free, open source, simpler
- **Bartender** - Feature-rich, paid
- **Vanilla** - Free, minimalist

**Impact:**
- ice-bar is not special; easy to swap out
- Configuration is minimal (just enable the service)
- Any alternative provides the same value

### Three-Layer Package Management

**Why:** The system uses Nix + Homebrew + mise instead of just Nix.

**Reasons:**

| Tool | Purpose | Why Not Nix? |
|------|---------|--------------|
| **Nix** | CLI tools, development utilities | Primary package manager |
| **Homebrew** | GUI Mac apps | Better native integration, automatic updates |
| **mise** | Runtime versions | Per-project version management, faster than Nix shells |

**Impact:**
- More complexity than pure Nix
- Better compatibility with macOS ecosystem
- Faster project switching with mise vs. Nix shells

> [!TIP]
> This layered approach prioritizes practical developer experience over theoretical purity.

## Known Limitations

### Homebrew Cleanup Policy

**Setting:** `homebrew.onActivation.cleanup = "zap"`

**Impact:** Any Homebrew packages installed manually (not declared in config) will be **removed** on the next rebuild.

**Workaround:**
- Declare all packages in `darwin/homebrew/*.nix`
- Or temporarily change to `cleanup = "uninstall"` (less aggressive)
- Or disable cleanup entirely (not recommended)

> [!CAUTION]
> If you `brew install something` manually, it will be removed on the next `darwin-rebuild switch`.

### Not All macOS Settings Are Declarative

**Limitation:** nix-darwin doesn't expose all macOS system preferences.

**Examples of what requires manual steps:**
- Some Mission Control settings
- Detailed notification preferences
- Certain accessibility options
- Third-party app preferences

**Workaround:** Use `system.activationScripts` to run `defaults write` commands:

```nix
system.activationScripts.postActivation.text = ''
  # Custom settings not in nix-darwin
  defaults write com.apple.dock show-process-indicators -bool true
  killall Dock
'';
```

> [!NOTE]
> These activation scripts run on every rebuild, so they're somewhat declarative but not validated by Nix.

### LaunchAgent Limitations

**Issue:** LaunchAgents sometimes fail to start or restart properly.

**Symptoms:**
- Services not running after rebuild
- Need to manually start services

**Workaround:**
```bash
# List agents
launchctl list | grep nix-darwin

# Restart specific agent
launchctl kickstart -k gui/$(id -u)/org.nixos.aerospace

# Or reboot (most reliable)
```

> [!TIP]
> After significant configuration changes, a full reboot is often cleaner than trying to restart individual services.

### Nix Store Disk Usage

**Issue:** The Nix store (`/nix/store/`) grows over time with multiple generations.

**Mitigation:** Automatic garbage collection is configured:
```nix
nix.gc = {
  automatic = true;
  interval = {Weekday = 7;}; # Sundays
  options = "--delete-older-than 30d";
};
```

**Manual cleanup:**
```bash
# See what would be deleted
nix-store --gc --print-dead

# Delete old generations
nix-collect-garbage -d

# Delete generations older than 30 days
nix-collect-garbage --delete-older-than 30d
```

> [!WARNING]
> After garbage collection, you cannot rollback to deleted generations.

### Intel vs. Apple Silicon

**Issue:** Some packages have different availability or behavior on Intel vs. ARM Macs.

**Current approach:**
- System architecture is specified per machine in `flake.nix`
- `M3419` and `macmini01` use `aarch64-darwin` (Apple Silicon)
- `mbp01` uses `x86_64-darwin` (Intel)

**Potential issues:**
- Some Homebrew casks may not support both architectures
- Nix binary cache availability varies
- Some software may require Rosetta 2 on Apple Silicon

**Check architecture:**
```bash
nix eval --raw .#darwinConfigurations.M3419.system.system
# Output: aarch64-darwin
```

### Git Commit Signing Requires 1Password

**Dependency:** Git commit signing is configured to use 1Password SSH agent.

**Impact:**
- Requires 1Password desktop app installed and running
- Requires SSH key stored in 1Password
- Commits will fail if 1Password is not unlocked

**Configuration:**
```nix
# home-manager/git.nix
programs.git.extraConfig = {
  gpg.format = "ssh";
  gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  user.signingkey = "ssh-ed25519 AAAAC3... (from 1Password)";
  commit.gpgsign = true;
};
```

**Workaround:** Disable signing if 1Password is unavailable:
```bash
git config --global commit.gpgsign false
```

### Private Information in Configuration

**Issue:** The configuration contains user-specific information that should be changed when forking.

**Examples:**
- Git username and email
- SSH keys
- AWS profiles
- 1Password vault references
- Machine hostnames

> [!IMPORTANT]
> If you fork this repository, search and replace personal information with your own before building.

**Key files to update:**
- `home-manager/git.nix` - Git identity and signing key
- `home-manager/zsh.nix` - AWS profiles and shell aliases
- `flake.nix` - Machine hostnames and usernames
- `scripts/*` - SAML2AWS and other personal scripts

## Flake Input Versions

### Update Frequency

**Strategy:** Manual updates via `nix flake update`

**Reasoning:**
- Automatic updates can break things unexpectedly
- Manual updates allow testing before committing
- `flake.lock` ensures reproducibility

**Recommended schedule:**
```bash
# Monthly update cycle
nix flake update
darwin-rebuild switch --flake .
# Test thoroughly
git add flake.lock
git commit -m "Update flake inputs"
```

### Pinned vs. Unstable

**Current approach:**
- Most inputs use `nixos-unstable` for latest packages
- No pinning to specific versions (rolling release approach)

**Alternative approaches:**

| Strategy | Pros | Cons |
|----------|------|------|
| **Unstable** (current) | Latest packages, newest features | Occasional breakage |
| **Stable** (23.11, etc.) | Very stable, tested | Outdated packages |
| **Pinned commits** | Complete control | Manual update burden |

**Change to stable:**
```nix
# flake.nix
inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
```

## Configuration Validation

### Type Checking

Nix provides type checking for options:
```bash
# Check configuration
nix flake check

# Show option types
nix-darwin-option darwin.defaults.dock.tilesize
```

### Syntax Errors

**Common mistakes:**
```nix
# Wrong: Missing semicolon
home.packages = with pkgs; [
  git
  vim
]

# Correct:
home.packages = with pkgs; [
  git
  vim
];

# Wrong: Using comma instead of semicolon
{
  programs.git.enable = true,
  programs.zsh.enable = true,
}

# Correct:
{
  programs.git.enable = true;
  programs.zsh.enable = true;
}
```

## Security Considerations

### No Secrets in Git

> [!CAUTION]
> Never commit secrets (API keys, tokens, passwords) to the repository.

**Safe patterns:**
- Use 1Password CLI to inject secrets at runtime
- Use environment variables from secure sources
- Use `op://vault/item/field` references in shell config

**Unsafe patterns:**
```nix
# NEVER do this:
environment.variables = {
  API_KEY = "sk_live_xxxxxxxxxxxxx"; # ❌ EXPOSED IN GIT
};

# Do this instead:
# In .envrc (gitignored) or via 1Password
export API_KEY="op://Private/API/key" # ✓ Safe
```

### File Permissions

**Issue:** Nix store files are world-readable.

**Impact:** Don't store secrets in Nix-managed files (they end up in `/nix/store/` which is readable by all users).

**For sensitive configs:** Use home-manager's `home.file` with symlinks:
```nix
home.file.".ssh/config".source = config.lib.file.mkOutOfStoreSymlink 
  "/Users/${username}/.config/ssh/config";
```

## Performance Considerations

### Build Times

**First build:** 10-30 minutes (downloads many packages)
**Subsequent builds:** 1-5 minutes (only changed derivations)

**Speed up builds:**
```bash
# Use binary cache (should be default)
nix.settings.substituters = [
  "https://cache.nixos.org"
];

# Parallel builds
nix.settings.max-jobs = 8; # Adjust to your CPU cores
```

### Evaluation Performance

**Slow evaluation:** If `darwin-rebuild` evaluation is slow:
```bash
# Clear evaluation cache
rm -rf ~/.cache/nix

# Check for circular imports
nix-instantiate --eval --strict flake.nix
```

## Compatibility

### macOS Versions

**Tested on:**
- macOS Sonoma (14.x)
- macOS Ventura (13.x)

**Likely compatible:**
- macOS Sequoia (15.x)

**May have issues:**
- Older versions (Big Sur and earlier)

### Nix vs. Lix

**Current:** Uses Lix (Nix fork)

**Lix differences:**
- Better error messages
- Improved performance
- Community-driven development

**Compatibility:** Nearly 100% compatible with Nix. Can switch back to Nix by reinstalling:
```bash
# Uninstall Lix
/nix/receipt.json # Check installer receipt for uninstall command

# Install Nix
sh <(curl -L https://nixos.org/nix/install)
```

## Debugging Tips

### Verbose Output

```bash
# More detailed output
darwin-rebuild switch --flake . --show-trace

# Maximum verbosity
darwin-rebuild switch --flake . --show-trace -L
```

### Check Derivation

```bash
# See what will be built
nix derivation show .#darwinConfigurations.M3419.system

# Build without switching
nix build .#darwinConfigurations.M3419.system
```

### Inspect Options

```bash
# List all options
nix-darwin-option --help

# Check specific option
nix-darwin-option system.defaults.dock
```

## Migration Guide

### From Fresh macOS Install

See [Getting Started](./getting-started.md).

### From Existing Dotfiles

1. **Backup current dotfiles:**
   ```bash
   mv ~/.zshrc ~/.zshrc.backup
   mv ~/.gitconfig ~/.gitconfig.backup
   ```

2. **Review and merge configurations:**
   - Compare your old configs with `home-manager/*.nix`
   - Copy useful aliases, functions, and settings

3. **Build and test:**
   ```bash
   darwin-rebuild switch --flake .
   ```

4. **Iterate:**
   - Fix any missing functionality
   - Add your custom configurations

### From This Repository

If forking:

1. **Update personal information:**
   ```bash
   # Search for hardcoded values
   rg "faizhasim" .
   rg "faiz.hasim@gmail.com" .
   ```

2. **Update machine names:**
   ```bash
   # Rename machines in flake.nix
   # Update darwin/homebrew/{hostname}.nix
   # Update home-manager/packages/{hostname}.nix
   ```

3. **Configure 1Password:**
   - Update SSH key in `home-manager/git.nix`
   - Set up 1Password shell plugins
   - Configure op CLI

4. **Test build:**
   ```bash
   darwin-rebuild switch --flake .#yourhostname
   ```

## Additional Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/index.html)
- [home-manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive into Nix
- [Zero to Nix](https://zero-to-nix.com/) - Beginner-friendly guide

## Getting Help

If you encounter issues:

1. Review Nix/nix-darwin documentation
2. Search existing issues (if public repo)
3. Ask in Nix community forums:
   - [NixOS Discourse](https://discourse.nixos.org/)
   - [r/NixOS Reddit](https://reddit.com/r/NixOS)
   - Nix Discord server
