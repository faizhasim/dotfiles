{ config, pkgs, ... }:

{
  # Dock settings that are directly supported by nix-darwin
  system.defaults = {
    dock = {
      # Icon size of Dock items
      tilesize = 36;
      # Dock magnification
      magnification = true;
      # Icon size of magnified Dock items
      largesize = 64;
      # Minimization effect: 'genie', 'scale', 'suck'
      mineffect = "scale";
      # Dock orientation: 'left', 'bottom', 'right'
      orientation = "left";
      # Minimize to application
      minimize-to-application = true;
      # Show indicators for open applications
      show-process-indicators = true;
      # Show recent applications in Dock
      show-recents = false;
      # Highlight hover effect for the grid view of a stack
      mouse-over-hilite-stack = true;

      # Optional settings (these are generally supported)
      # autohide = true;
      # showhidden = true;

      autohide = false;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      dashboard-in-overlay = true;
#      largesize = 85;
#      tilesize = 50;
#      magnification = true;
      launchanim = false;
      mru-spaces = false;
#      show-recents = false;
#      show-process-indicators = false;
      static-only = true;
    };

    NSGlobalDomain = {
      # Prefer tabs when opening documents: 'always', 'fullscreen', 'manual'
      AppleWindowTabbingMode = "manual";

      _HIHideMenuBar = false;
    };
  };

  # For options that aren't directly supported by nix-darwin
  system.activationScripts.extraDockSettings.text = ''
    # Lock the Dock size
    defaults write com.apple.dock size-immutable -bool true

    # Spring loaded Dock items
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

    # Dock pinning: 'start', 'middle', 'end'
    defaults write com.apple.dock pinning -string "middle"

    # Double-click a window's title bar to maximize
    defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Maximize"

    # Flag for Launchpad in the Dock
    defaults write com.apple.dock checked-for-launchpad -bool true

    # Lock the Dock position
    # defaults write com.apple.dock position-immutable -bool true

    # Lock the Dock contents
    # defaults write com.apple.dock contents-immutable -bool true

    # Animation for opening applications
    # defaults write com.apple.dock launchanim -bool false

    # Static only (show only open applications)
    # defaults write com.apple.dock static-only -bool true

    # Uncomment to add a spacer to the left side of the Dock
    # defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'

    # Uncomment to remove all default app icons from the Dock
    # defaults write com.apple.dock persistent-apps -array
  '';
}