{ inputs, ... }:
[
  (import ./worktrunk.nix { inherit inputs; })
  (import ./shellcheck-fix.nix { })
  (import ./nushell-fix.nix { })
  (import ./opencode-dummy.nix { })
  (import ./kubernetes-helm-fix.nix { })
  (import ./mise-fix.nix { })
  (import ./sqlfluff-fix.nix { })
]
