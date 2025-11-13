# Getting Started

This guide will walk you through setting up this Nix-based macOS configuration from scratch.

## Prerequisites

Before you begin, ensure you have:
- A Mac running macOS (Intel or Apple Silicon)
- Administrative access to your machine
- Internet connection
- Basic familiarity with terminal commands

## Installation Steps

### 1. Install Homebrew

Homebrew must be installed manually before applying the Nix configuration.

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> [!IMPORTANT]
> **Why Manual?** We don't use nix-homebrew because it manages taps as flake inputs, making it difficult to work with private GitHub repositories. By installing Homebrew manually, we maintain flexibility while letting nix-darwin manage the packages.

### 2. Bootstrap macOS Development Tools

Install Xcode command line tools:

```shell
xcode-select --install
```

### 3. Install Lix

Lix is a Nix implementation that comes with nix-darwin by default:

```shell
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

> [!NOTE]
> Lix includes nix-darwin automatically, so you don't need a separate installation.

### 4. Clone This Repository

```shell
git clone https://github.com/faizhasim/dotfiles.git ~/dev/faizhasim/dotfiles
cd ~/dev/faizhasim/dotfiles
```

### 5. Apply Nix-Darwin Configuration

Choose the command that matches your machine:

```shell
# For M3419 (Apple Silicon)
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .#M3419

# For macmini01 (Apple Silicon)
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .#macmini01

# For mbp01 (Intel Mac)
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .#mbp01
```

> [!TIP]
> The first run will take longer as it downloads and builds all packages. Subsequent runs are much faster.

### 6. Complete Manual Setup Steps

Some configurations can't be automated and require manual intervention.

#### 6.4 AI Assistant Setup

The system includes Context7-enabled prompts for smarter workflows. These prompts prioritise up-to-date documentation and efficient task execution. No additional setup is required, but you can learn more in the [AI Agents](./index.md#ai-assisted-development) section.

#### 6.1 Karabiner-Elements

1. Open Karabiner-Elements
2. Go to **Complex Modifications**
3. Click **Add predefined rule**
4. Enable the rule that changes CMD+TAB to use Raycast

> [!NOTE]
> This remapping allows you to use Raycast's superior window switcher instead of the default macOS app switcher.

#### 6.2 Configure saml2aws

If you use AWS with SAML authentication:

```shell
export OP_ITEM="your-1password-item-name"
./scripts/saml2aws-configure.sh
```

This script pulls credentials from 1Password and configures saml2aws.

#### 6.3 Setup Neovim

The Neovim configuration is managed separately using GNU Stow:

```shell
./scripts/setup-nvim.sh
```

This script will:
- Symlink the nvim configuration to `~/.config/nvim`
- Install mise-managed tools
- Enable corepack for Node.js
- Install global npm packages (GitHub Copilot, OpenCode, markdown-toc)

After running this, launch `nvim` and let LazyVim download and configure all plugins automatically.

## Post-Installation

### Verify Installation

Check that key commands are available:

```shell
# Check Nix
nix --version

# Check installed tools
which aerospace
which wezterm
which nvim

# Check shell configuration
echo $EDITOR  # Should show: nvim
```

### Understanding darwin-rebuild

After the initial setup, you can rebuild your system configuration without `sudo`:

```shell
# Rebuild and switch to new configuration
darwin-rebuild switch --flake .#M3419

# Just build without switching
darwin-rebuild build --flake .#M3419

# See what would change
darwin-rebuild dry-run --flake .#M3419
```

### Updating Your System

To update all flake inputs (nixpkgs, home-manager, etc.):

```shell
nix flake update
darwin-rebuild switch --flake .#M3419
```

## Next Steps

Now that you have the basic setup:

1. Read the [Architecture](./architecture.md) guide to understand how everything fits together
2. Review the [Configuration Guide](./configuration-guide.md) to customize your setup
3. Bookmark the [Reference](./reference.md) page for important gotchas and limitations
4. Check the [Reference](./reference.md) for important gotchas and limitations

## Getting Help

If you encounter issues:

1. Review the [Reference](./reference.md) guide for known limitations
2. Review recent commits for breaking changes
3. Open an issue on GitHub with:
   - Your machine type (M3419, macmini01, mbp01)
   - macOS version
   - Error messages and logs
   - Steps to reproduce

> [!TIP]
> Most issues during first-time setup are related to Homebrew not being installed or not being in your PATH. Make sure `/opt/homebrew/bin` (Apple Silicon) or `/usr/local/bin` (Intel) is in your PATH.
