{ config, pkgs, lib, inputs, user, ... }: {
 home = {
   enableNixpkgsReleaseCheck = false;
   packages = pkgs.callPackage ./packages.nix {};
   stateVersion = "23.11";
 };

 imports = [
  (import ./aerospace.nix { inherit config pkgs lib inputs user; })
  ./shell.nix
  ./sketchybar.nix
  ./wezterm.nix
  ./zsh.nix
 ];

}