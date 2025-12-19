{ pkgs, ... }:

{
  stylix = {
    enable = true;
    enableReleaseChecks = false; # Suppress version mismatch warnings for unstable channel
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
  };
}
