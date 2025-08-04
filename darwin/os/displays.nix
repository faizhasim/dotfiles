{ config, pkgs, ... }:

{
  # Settings that can be applied through nix-darwin
  system.defaults.NSGlobalDomain = {
    # Subpixel font rendering on non-Apple LCDs (2 = Medium)
    AppleFontSmoothing = 0;
  };

  # For settings that need system-level permissions or are not directly supported
  system.activationScripts.displaySettings.text = ''
    # Automatically adjust brightness
    defaults write com.apple.BezelServices dAuto -bool true
    sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool true

    # Enable HiDPI display modes (requires restart)
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

    # Show mirroring options in the menu bar when available
    defaults write com.apple.airplay showInMenuBarIfPresent -bool true
  '';
}