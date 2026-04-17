{ inputs, ... }:
[
  (import ./ice-bar.nix)
  (import ./worktrunk.nix { inherit inputs; })
  (import ./shellcheck-fix.nix { })
  (import ./nushell-fix.nix { })
  (import ./opencode-dummy.nix { })
]
