# Overlay to skip sqlfluff test suite during rebuild
# Tests take very long (10k+ pytest items) and are unrelated to our builds
_:

(final: prev: {
  sqlfluff = prev.sqlfluff.overrideAttrs (oldAttrs: {
    dontUsePytestCheck = true;
    doInstallCheck = false;
  });
})
