{ config, pkgs, ... }:

{
  # Mission Control settings that are directly supported
  system.defaults = {
    dock = {
      # Mission Control animation duration
      expose-animation-duration = 0.1;

      # Optional settings (uncomment if needed)
      # mru-spaces = false;  # Don't automatically rearrange Spaces
      # expose-group-by-app = false;  # Don't group windows by application
      # showLaunchpadGestureEnabled = 0;  # Disable Launchpad gesture
    };

    # Optional NSGlobalDomain settings (uncomment if needed)
    # NSGlobalDomain = {
    #   AppleSpacesSwitchOnActivate = true;  # Switch to app's space when switching apps
    # };
  };

  # For settings that need user-specific paths or aren't directly supported
  system.activationScripts.missionControlSettings.text = ''
    # Hot corners settings (0 = No action)
    # Top left screen corner
    defaults write com.apple.dock wvous-tl-corner -int 0
    defaults write com.apple.dock wvous-tl-modifier -int 0

    # Top right screen corner
    defaults write com.apple.dock wvous-tr-corner -int 0
    defaults write com.apple.dock wvous-tr-modifier -int 0

    # Bottom left screen corner
    defaults write com.apple.dock wvous-bl-corner -int 0
    defaults write com.apple.dock wvous-bl-modifier -int 0

    # Bottom right screen corner
    defaults write com.apple.dock wvous-br-corner -int 0
    defaults write com.apple.dock wvous-br-modifier -int 0

    # Reset Launchpad
    find "$HOME/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

    # Displays have separate Spaces (commented out by default)
    # defaults write com.apple.spaces spans-displays -bool false

    # Add iOS Simulator to Launchpad (uncomment if needed)
    # if [ -e "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" ]; then
    #   sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
    # fi
  '';
}