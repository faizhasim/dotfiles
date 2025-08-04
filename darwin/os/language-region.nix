{ config, pkgs, ... }:

{
  # For language and region settings
  system.activationScripts.languageSettings.text = ''
    # Preferred languages (in order of preference)
    defaults write NSGlobalDomain AppleLanguages -array "en-MY"

    # Currency/locale
    defaults write NSGlobalDomain AppleLocale -string "en_MY"

    # Measurement units
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"

    # Force 24-hour time
    defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

    # Optional settings (uncomment if needed)
    # defaults write NSGlobalDomain AppleICUForce12HourTime -bool true
    # defaults write NSGlobalDomain AppleMetricUnits -bool true

    # Show language menu in the boot screen
    # sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true
  '';
}