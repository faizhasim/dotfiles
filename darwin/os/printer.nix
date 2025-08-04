{ config, pkgs, ... }:

{
  # Printing settings through nix-darwin's system defaults
  system.defaults.NSGlobalDomain = {
    # Expand print panel by default
    PMPrintingExpandedStateForPrint = true;
    PMPrintingExpandedStateForPrint2 = true;
  };

  # For settings that might not be directly supported
  system.activationScripts.printerSettings.text = ''
    # Automatically quit printer app once the print jobs complete
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
  '';
}