# Architecture

This document explains how the dotfiles system is structured and how different components work together.

## Overview

The configuration uses a **layered architecture** where each layer has specific responsibilities:

```
┌─────────────────────────────────────────┐
│         flake.nix (Entry Point)         │
│  - Defines inputs & outputs             │
│  - Creates machine configurations       │
└─────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
┌──────────────┐        ┌──────────────┐
│   darwin/    │        │ home-manager/│
│ System Level │        │  User Level  │
└──────────────┘        └──────────────┘
        │                       │
    ┌───┴────┐          ┌──────┴──────┐
    ▼        ▼          ▼             ▼
  os/    homebrew/   packages/   configs/
```

## Directory Structure

```
dotfiles/
├── flake.nix                # Entry point, defines all inputs/outputs
├── flake.lock              # Locked dependency versions
│
├── darwin/                 # System-level configuration (nix-darwin)
│   ├── default.nix        # Main darwin module
│   ├── stylix.nix         # Nord theme configuration
│   ├── os/                # macOS system preferences
│   │   ├── dock.nix
│   │   ├── finder.nix
│   │   ├── keyboard.nix
│   │   └── ...
│   └── homebrew/          # Homebrew package definitions
│       ├── default.nix
│       ├── common.nix     # Shared across all machines
│       ├── M3419.nix      # Machine-specific overrides
│       └── ...
│
├── home-manager/          # User-level configuration
│   ├── default.nix       # Main home-manager module
│   ├── packages/         # Package lists per machine
│   │   ├── common.nix
│   │   └── M3419.nix
│   ├── zsh.nix           # Shell configuration
│   ├── git.nix           # Git settings
│   ├── wezterm.nix       # Terminal config
│   ├── aerospace.nix     # Window manager
│   └── ...               # Other tool configurations
│
├── nvim/                  # Neovim configuration (managed by stow)
│   └── lua/
│       ├── config/
│       └── plugins/
│
├── overlays/              # Package modifications
│   └── ice-bar.nix       # Custom ice-bar version
│
├── scripts/               # Setup and utility scripts
│   ├── setup-nvim.sh
│   └── saml2aws-configure.sh
│
└── docs/                  # Documentation
```

## Core Components

### 1. Flake (flake.nix)

The entry point that defines:

- **Inputs**: External dependencies (nixpkgs, home-manager, darwin, etc.)
- **Outputs**: System configurations for each machine
- **Configuration function**: `createDarwin` that assembles everything

Key aspects:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin.url = "github:LnL7/nix-darwin/master";
    home-manager.url = "github:nix-community/home-manager";
    # ... other inputs
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }: {
    darwinConfigurations = {
      M3419 = createDarwin "M3419" "faizhasim" "aarch64-darwin";
      # ... other machines
    };
  };
}
```

### 2. Darwin Configuration (darwin/)

Manages **system-level** macOS settings using nix-darwin.

#### darwin/os/

Contains granular macOS system preference modules:

- **dock.nix** - Dock appearance, position, behavior
- **finder.nix** - Finder preferences, file extensions
- **keyboard.nix** - Key repeat, autocorrect settings
- **trackpad.nix** - Trackpad gestures and sensitivity
- **security-privacy.nix** - Firewall, FileVault settings
- **And more...** - Each aspect of macOS in its own file

> [!NOTE]
> Not all macOS settings can be managed declaratively. Some require `defaults write` commands in activation scripts.

#### darwin/homebrew/

Defines applications installed via Homebrew:

- **common.nix** - Packages shared across all machines
- **{hostname}.nix** - Machine-specific packages

Structure:
```nix
{
  brews = []; # CLI tools from Homebrew
  casks = []; # GUI applications
  taps = [];  # Custom repositories
  masApps = {}; # Mac App Store apps
}
```

> [!IMPORTANT]
> Homebrew cleanup is set to `"zap"`, which removes manually installed packages. Only packages declared in these files will remain.

#### darwin/stylix.nix

Applies the Nord color scheme system-wide using Stylix.

### 3. Home Manager Configuration (home-manager/)

Manages **user-level** configurations and dotfiles.

#### home-manager/packages/

Package lists organized by machine:

- **common.nix** - Core packages used on all machines (~170 packages)
- **{hostname}.nix** - Machine-specific additions

Categories include:
- Development tools (go, rust, terraform, kubectl)
- CLI utilities (bat, fd, ripgrep, fzf)
- Media tools (ffmpeg, imagemagick)
- System tools (btop, htop, fswatch)

#### home-manager/configs/

Individual tool configurations:

- **zsh.nix** - Shell setup, aliases, functions, plugins
- **git.nix** - Git config, aliases, 1Password signing
- **wezterm.nix** - Terminal emulator settings
- **aerospace.nix** - Window manager configuration
- **mise.nix** - Runtime version manager (node, python, go, etc.)
- **direnv.nix** - Per-directory environment management

> [!TIP]
> Each tool config is a separate module, making it easy to enable/disable features.

### 4. Neovim (nvim/)

Neovim is managed **outside of Nix** using:
- **LazyVim** distribution as the base
- **GNU Stow** for symlinking configs
- **Lazy.nvim** for plugin management

Why separate from Nix?
- Faster iteration during plugin experimentation
- Better compatibility with LazyVim's update mechanism
- Simpler management of Lua-based configurations

The configuration includes:
- Language servers for Go, TypeScript, Python, Nix, etc.
- GitHub Copilot and Sidekick integration
- Custom keybindings and UI tweaks
- Mini.files, Snacks.nvim, and other modern plugins

### 5. Overlays (overlays/)

Package modifications and custom versions:

```nix
# overlays/ice-bar.nix
final: prev: {
  ice-bar = prev.ice-bar.overrideAttrs (old: {
    version = "0.11.13-dev.2";
    src = final.fetchurl { ... };
  });
}
```

Currently only customizes ice-bar to use a specific development version.

## Configuration Flow

### Build Process

1. **Flake evaluation** - Nix reads `flake.nix` and resolves inputs
2. **Machine selection** - Based on `--flake .#{hostname}` argument
3. **Darwin build** - System-level configs applied via nix-darwin
4. **Home-manager build** - User configs applied via home-manager
5. **Activation scripts** - Run `defaults write` commands for macOS settings
6. **LaunchAgents** - Start services (AeroSpace, etc.)

### Machine-Specific Configuration

The system supports three machines with shared base config + overrides:

```nix
# Package resolution example
packages = common ++ machineSpecific

# Where:
# common.nix = [aerospace bat git ...]
# M3419.nix = [additional-tool-for-M3419 ...]
```

Same pattern applies to:
- Nix packages (`home-manager/packages/`)
- Homebrew packages (`darwin/homebrew/`)

## Service Management

### LaunchAgents

Services are managed via launchd:

```nix
# Example: AeroSpace window manager
launchd.user.agents.aerospace = {
  command = "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
  serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardOutPath = "/tmp/aerospace.log";
    StandardErrorPath = "/tmp/aerospace.err.log";
  };
};
```

### System Services

- **AeroSpace** - Window tiling manager
- **borders** - Window border highlighting (via Homebrew)
- **ice-bar** - Menu bar replacement

## Package Management Strategy

The system uses **three layers** of package management:

### Layer 1: Nix (Primary)

**What:** CLI tools, development utilities, some GUI apps
**Why:** Declarative, reproducible, version-controlled
**Examples:** neovim, git, kubectl, wezterm

```nix
home.packages = with pkgs; [
  neovim
  git
  kubectl
];
```

### Layer 2: Homebrew (GUI Apps)

**What:** Mac-native GUI applications
**Why:** Better integration with macOS, official distribution
**Examples:** 1Password, Obsidian, Firefox

```nix
homebrew.casks = [
  "1password"
  "obsidian"
  "firefox"
];
```

### Layer 3: mise (Runtime Versions)

**What:** Language runtimes and project-specific tools
**Why:** Per-project version management
**Examples:** Node.js, Python, Go versions

```nix
programs.mise = {
  enable = true;
  globalConfig.tools = {
    node = "lts";
    python = ["3.11"];
    go = "1.25.3";
  };
};
```

> [!NOTE]
> **mise** (formerly rtx) integrates with **direnv** to automatically activate project-specific environments.

## Security Architecture

### 1Password Integration

The system deeply integrates with 1Password:

```
┌──────────────┐
│  1Password   │
│  (Secrets)   │
└──────┬───────┘
       │
   ┌───┴────┬──────────┬────────────┐
   ▼        ▼          ▼            ▼
Git      Shell     npm/pnpm     saml2aws
Signing  Plugins   Tokens       AWS Auth
```

Key integrations:
- **Git commit signing** via SSH with 1Password agent
- **Shell plugins** for secure credential injection
- **npm/pnpm** credentials via `op run`
- **GitHub CLI** via `op plugin run`

### Secret Management

> [!CAUTION]
> No secrets should ever be committed to this repository. All sensitive data is pulled from 1Password at runtime.

Example secure pattern:
```bash
# Bad: Hardcoded token
export NPM_TOKEN="npm_xxxxxxxxxxxx"

# Good: Pulled from 1Password
npm="op run --env-file=$HOME/.config/op-env/npm-env -- npm"
```

## Theme System (Stylix)

Stylix provides system-wide theming based on base16 color schemes:

```nix
stylix = {
  enable = true;
  base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
};
```

This automatically themes:
- Terminal colors
- Shell prompts
- Potentially other compatible applications

> [!TIP]
> The Nord theme is also manually applied to nvim and other tools that don't support Stylix integration.

## Update Strategy

### Automatic Updates

- **Homebrew packages** - Auto-update enabled
- **Nix garbage collection** - Runs weekly (Sundays at 2 AM)
  - Deletes generations older than 30 days

### Manual Updates

```bash
# Update flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# Rebuild with new inputs
darwin-rebuild switch --flake .#M3419

# Update Homebrew separately
brew update && brew upgrade
```

## Next Steps

- Learn how to customize in the [Configuration Guide](./configuration-guide.md)
- Understand important caveats in the [Reference](./reference.md)
