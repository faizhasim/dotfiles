{ inputs, ... }:
[
  (import ./ice-bar.nix)
  (import ./worktrunk.nix { inherit inputs; })
]
