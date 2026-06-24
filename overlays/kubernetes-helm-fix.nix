# kubernetes-helm 4.2.0 checkPhase references dependency_build_test.go which
# no longer exists in that release. Disable the broken check until nixpkgs fixes it.
_: final: prev: {
  kubernetes-helm = prev.kubernetes-helm.overrideAttrs (_: {
    doCheck = false;
  });
}
