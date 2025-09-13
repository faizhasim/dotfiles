
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

```shell
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .#M1196
```


[Lix]: https://lix.systems/install/

