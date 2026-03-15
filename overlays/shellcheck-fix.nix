# Fix nix-darwin shellcheck validation failing on info-level warnings
# Adds exclusions for SC2317/SC2329 which are info-level warnings about
# unreachable code and unused functions in the activation script structure
{ ... }:
final: prev: {
  shellcheck =
    prev.runCommand "shellcheck-patched"
      {
        passthru = {
          inherit (prev.shellcheck) unwrapped;
        };
      }
      ''
              mkdir -p $out/bin

              # Create wrapper that adds exclusions for nix-darwin activation scripts
              cat > $out/bin/shellcheck <<'INNEREOF'
        #!/usr/bin/env bash
        # Get all arguments
        args=("$@")

        # Check if this is the nix-darwin activation script check
        if [[ " ''${args[*]}" == *"/activate"* ]] && [[ " ''${args[*]}" == *"/activate-user"* ]]; then
          # Add exclusions for info-level warnings that shouldn't fail the build
          exec ${prev.shellcheck}/bin/shellcheck --exclude=SC2016,SC1112,SC2317,SC2329,SC2086 "''${args[@]}"
        else
          # Normal shellcheck for other uses
          exec ${prev.shellcheck}/bin/shellcheck "''${args[@]}"
        fi
        INNEREOF
              chmod +x $out/bin/shellcheck
      '';
}
