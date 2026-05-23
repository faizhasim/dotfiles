{ inputs, ... }:
[
  (import ./worktrunk.nix { inherit inputs; })
  (import ./shellcheck-fix.nix { })
  (import ./nushell-fix.nix { })
  (import ./opencode-dummy.nix { })
]
