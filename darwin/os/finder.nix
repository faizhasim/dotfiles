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
      CreateDesktop = true;
      FXDefaultSearchScope = "SCcf"; # current folder
      QuitMenuItem = true;
    };
  };
}
