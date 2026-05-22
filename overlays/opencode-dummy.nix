# Dummy opencode package for home-manager module compatibility
# The real opencode binary comes from bun (bun add -g opencode-ai), but
# home-manager's opencode module requires a package for its version checks.
_: final: prev: {
  opencode-dummy = prev.stdenvNoCC.mkDerivation {
    pname = "opencode";
    version = "999.0.0"; # High version to satisfy versionAtLeast checks
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
            mkdir -p $out/bin
            # Proxy to the bun-installed binary (~/.bun/bin/opencode)
            cat > $out/bin/opencode << 'EOF'
      #!/bin/sh
      exec "$HOME/.bun/bin/opencode" "$@"
      EOF
            chmod +x $out/bin/opencode
    '';
  };
}
