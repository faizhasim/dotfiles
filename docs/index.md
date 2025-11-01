# Dotfiles Documentation

Welcome to the documentation for this Nix-based macOS configuration system.

## What is This?

This is a **declarative macOS system configuration** that uses Nix/Lix and nix-darwin to manage your entire development environment as code. Everything from system preferences to installed applications to shell configurations is version-controlled and reproducible.

## Quick Links

- **[Getting Started](./getting-started.md)** - Installation and setup instructions
- **[Architecture](./architecture.md)** - How the system is structured
- **[Configuration Guide](./configuration-guide.md)** - Customizing your setup
- **[Reference](./reference.md)** - Gotchas, limitations, and important notes

## Key Features

- 🎯 **Declarative Configuration** - Your entire system as code
- 🔄 **Reproducible** - Same configuration across multiple machines
- 🎨 **Nord Theme** - Consistent aesthetic system-wide via Stylix
- 🔒 **Security-First** - 1Password integration for secrets management
- 🪟 **Tiling Window Manager** - AeroSpace for keyboard-driven workflows
- 🛠️ **Developer-Focused** - Modern CLI tools, LSPs, and AI assistance
- 📦 **Multi-Layer Package Management** - Nix, Homebrew, and mise working together

## Philosophy

This configuration follows several core principles:

1. **Infrastructure as Code** - Everything version-controlled and reproducible
2. **Modular Design** - Separated concerns with clear boundaries
3. **Pragmatic Approach** - Using the right tool for each job
4. **Security by Default** - No secrets in code, 1Password integration
5. **Developer Experience** - Keyboard-driven, fast, and consistent

## Supported Machines

Currently configured for:
- **M3419** - Apple Silicon (aarch64-darwin)
- **macmini01** - Apple Silicon (aarch64-darwin)
- **mbp01** - Intel Mac (x86_64-darwin)

## What Gets Managed

### System Level (nix-darwin)
- macOS system preferences (Dock, Finder, keyboard, etc.)
- Fonts and display settings
- Security and privacy settings
- LaunchAgents for services

### User Level (home-manager)
- Shell configuration (Zsh with plugins)
- Git configuration and aliases
- Terminal emulator (WezTerm)
- Editor setup (Neovim/LazyVim)
- Window manager (AeroSpace)
- Status bar (ice-bar)
- Development tools and CLI utilities

### Applications
- **Nix packages** - CLI tools and some GUI apps
- **Homebrew casks** - Mac-specific GUI applications
- **App Store apps** - Via `mas` CLI

## Documentation Structure

This documentation follows a learning-oriented approach:

- Start with **[Getting Started](./getting-started.md)** for installation
- Read **[Architecture](./architecture.md)** to understand the system
- Use **[Configuration Guide](./configuration-guide.md)** to customize
- Refer to **[Reference](./reference.md)** for gotchas and limitations

## Contributing

This is a personal dotfiles repository, but you're welcome to:
- Fork it for your own use
- Open issues for bugs or questions
- Submit PRs for improvements

> [!TIP]
> Before forking, read the [Reference](./reference.md) documentation to understand important considerations and limitations.
