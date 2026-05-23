{ config, pkgs, ... }:

{
  # Language and region settings
  system.defaults.NSGlobalDomain = {
    # Use metric measurement units
    AppleMeasurementUnits = "Centimeters";

    # Force 24-hour time display
    AppleICUForce24HourTime = true;
  };

  # Settings without native nix-darwin support (AppleLanguages, AppleLocale)
  system.activationScripts.languageSettings.text = ''
    # Preferred languages (in order of preference)
    defaults write NSGlobalDomain AppleLanguages -array "en-MY"

    # Currency/locale
    defaults write NSGlobalDomain AppleLocale -string "en_MY"
  '';
}
