# Dummy opencode package for home-manager module compatibility
# The real opencode binary comes from Homebrew, but home-manager's
# opencode module requires a package with a version for its warnings logic.
_: final: prev: {
  opencode-dummy = prev.stdenvNoCC.mkDerivation {
    pname = "opencode";
    version = "999.0.0"; # High version to satisfy versionAtLeast checks
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
            mkdir -p $out/bin
            # Create a placeholder script that tells users to use homebrew
            cat > $out/bin/opencode << 'EOF'
      #!/bin/sh
      echo "Error: opencode should be installed via Homebrew, not Nix." >&2
      echo "Run: brew install opencode" >&2
      exit 1
      EOF
            chmod +x $out/bin/opencode
    '';
  };
}
