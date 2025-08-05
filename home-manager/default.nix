{ config, pkgs, lib, ... }: {
 home = {
   enableNixpkgsReleaseCheck = false;
   packages = pkgs.callPackage ./packages.nix {};
   stateVersion = "23.11";
 };

 imports = [
  ./aerospace.nix
  ./shell.nix
  ./sketchybar.nix
  ./wezterm.nix
  ./zsh.nix
 ];

}