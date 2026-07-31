# Overlay to skip pandas-stubs test suite
# Tests fail with pytest 9.1.1+ due to passing generators to parametrize.
# Imports check also fails because pandas is not available at build time.
_:
(final: prev: {
  python3 = prev.python3.override {
    packageOverrides = self: super: {
      pandas-stubs = super.pandas-stubs.overridePythonAttrs (oldAttrs: {
        doCheck = false;
        dontUsePythonImportsCheck = true;
      });
    };
  };
  python3Packages = final.python3.pkgs;
})
