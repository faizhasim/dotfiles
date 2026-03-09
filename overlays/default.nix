{ inputs, ... }:
[
  (import ./ice-bar.nix)
  (import ./zjstatus.nix { inherit inputs; })
  (import ./worktrunk.nix { inherit inputs; })
]
