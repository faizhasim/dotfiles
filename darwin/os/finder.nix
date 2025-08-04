{ config, pkgs, ... }:

{
  # General settings directly supported by nix-darwin
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
    };


    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf"; # current folder
      QuitMenuItem = true;
    };
  };
}