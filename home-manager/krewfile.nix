{ config, pkgs, lib, inputs, ... }: {
  programs.krewfile = {
    enable = true;
    krewPackage = pkgs.krew;
    plugins = [
      "ctx"
      "ktop"
      "ns"
      "stern"
      "tunnel"
      "view-secret"
      "whoami"
    ];
  };
}
