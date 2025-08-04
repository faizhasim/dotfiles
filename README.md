
## Installation

### Bootstrap OS

```shell
xcode-select --install
```

### Install Lix

```shell

```

### Install Nix-Darwin (do i need this?)

```shell
sudo nix run nix-darwin/master#darwin-rebuild -- switch
```


## Apply

### Apply Nix-Darwin Configuration

```shell
sudo nix run nix-darwin -- switch --flake .
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .
```