{ config, pkgs, lib, ... }: {
 home = {
   enableNixpkgsReleaseCheck = false;
   packages = pkgs.callPackage ./packages.nix {};
   stateVersion = "23.11";
 };

 imports = [
  ./shell.nix
  ./zsh.nix
 ];

}