{ config, pkgs, ... }:

{
  # General settings directly supported by nix-darwin
  # NOTE: AppleShowAllExtensions and AppleShowAllFiles are set via `finder` block below;
  # the equivalent NSGlobalDomain keys would be redundant.
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = true;
      FXDefaultSearchScope = "SCcf"; # current folder
      QuitMenuItem = true;
    };
  };
}
