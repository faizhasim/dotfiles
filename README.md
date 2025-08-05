
## Installation

### Bootstrap OS

```shell
xcode-select --install
```

### Install [Lix]

```shell
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

### Install Nix-Darwin

```shell
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin/master#darwin-rebuild -- switch
```


## Apply

### Apply Nix-Darwin Configuration

```shell
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .
```


[Lix]: https://lix.systems/install/