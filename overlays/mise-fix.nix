# Overlay to fix mise build on macOS
# Tests fail due to macOS-specific permission handling in OCI layer tests
_:

(final: prev: {
  mise = prev.mise.overrideAttrs (oldAttrs: {
    # Disable tests that fail in macOS sandbox
    doCheck = false;
  });
})
