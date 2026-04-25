# Overlay to fix nushell build on macOS
# Tests fail due to sandboxing issues with SHLVL
_:

(final: prev: {
  nushell = prev.nushell.overrideAttrs (oldAttrs: {
    # Disable tests that fail in macOS sandbox
    doCheck = false;
  });
})
