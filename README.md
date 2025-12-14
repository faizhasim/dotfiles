# Dotfiles

<!--toc:start-->

- [Dotfiles](#dotfiles)
  - [📚 Documentation](#📚-documentation)
    - [Quick Links](#quick-links)
  - [Quick Start](#quick-start)
    - [Prerequisite](#prerequisite)
  - [Installation](#installation)
    - [Bootstrap OS](#bootstrap-os)
    - [Install Lix](#install-lix)
  - [Apply](#apply)
    - [Apply Nix-Darwin Configuration](#apply-nix-darwin-configuration)
  - [Manual Steps](#manual-steps) - [Karabiner-Elements](#karabiner-elements) - [saml2aws](#saml2aws) - [setup nvim](#setup-nvim)

<!--toc:end-->

Declarative macOS system configuration using Nix/Lix, nix-darwin, and home-manager.

## 📚 Documentation

**New to this setup?** Start with the [complete documentation](./docs/index.md).

### Quick Links

- **[Getting Started](./docs/getting-started.md)** - Installation and setup
- **[Architecture](./docs/architecture.md)** - How the system works
- **[Configuration Guide](./docs/configuration-guide.md)** - Customise your setup
- **[Reference](./docs/reference.md)** - Gotchas and important notes
- **[AI Agents](./docs/index.md#ai-assisted-development)** - Learn about Context7-enabled prompts
- **[Neotest Guide](./docs/neotest.md)** - Testing in Neovim
- **[dnsmasq Guide](./docs/dnsmasq.md)** - Local DNS development

## Quick Start

### Prerequisite

Install [homebrew](https://brew.sh) separately:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> [!NOTE]
> As [nix-homebrew](https://github.com/zhaofengli/nix-homebrew) manage taps as
> flake inputs, this make hard to manage private taps from private Github.
> Hence, homebrew installation is manual and we'll let nix-darwin manage the rest.

## Installation

### Bootstrap OS

```shell
xcode-select --install
```

### Install [Lix]

```shell
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

> [!NOTE]
> nix-darwin comes by default with Lix installation

## Apply

### Apply Nix-Darwin Configuration

<!-- markdownlint-disable MD013 -->

```shell
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .#M3419
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .#macmini01
```

Or, once darwin-rebuild is installed:

```shell
sudo darwin-rebuild switch --flake .#M3419
sudo darwin-rebuild switch --flake .#macmini01
```

<!-- markdownlint-enable MD013 -->

[Lix]: https://lix.systems/install/

## Manual Steps

### Karabiner-Elements

- Complex Modifications: Add predefined rule to change CMD+TAB to use Raycast

### saml2aws

- Run [saml2aws-configure.sh](./scripts/saml2aws-configure.sh) to setup saml2aws.

### setup nvim

- Run [setup-nvim.sh](./scripts/setup-nvim.sh) to:
  - stow nvim config
  - install copilot cli
