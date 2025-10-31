# Prerequisite

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
