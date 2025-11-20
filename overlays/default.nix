{ inputs, ... }:
[
  (import ./ice-bar.nix)
  (import ./zjstatus.nix { inherit inputs; })
]
