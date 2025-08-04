{ config, pkgs, ... }:

{
  # General settings directly supported by nix-darwin
  system.defaults.NSGlobalDomain = {
    # Use Dark menu bar and Dock
    AppleInterfaceStyle = "Dark";

    # Sidebar icon size (1 = Small)
    NSTableViewDefaultSizeMode = 1;

    # Scroll bar visibility
    AppleShowScrollBars = "WhenScrolling";


    AppleScrollerPagingBehavior = true;

    # Optional settings (uncomment if needed)
    # AppleAquaColorVariant = 6;  # Graphite appearance
    # AppleHighlightColor = "0.780400 0.815700 0.858800";  # Graphite highlight
    # _HIHideMenuBar = true;  # Automatically hide and show the menu bar
    # NSScrollAnimationEnabled = false;  # Disable smooth scrolling
    # NSQuitAlwaysKeepsWindows = false;  # Close windows when quitting
  };

  # For settings that need user-specific paths or aren't directly supported
  system.activationScripts.generalSettings.text = ''
    # Allow Handoff between this Mac and iCloud devices
    defaults write ~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool true
    defaults write ~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool true

    # Display crash reports in Notification Center (instead of dialog)
    defaults write com.apple.CrashReporter UseUNC 1

    # Optional settings (uncomment if needed)
    # Disable Auto Save, Versions and Resume
    # defaults write -g ApplePersistence -bool false

    # Disable Crash Reporter dialog
    # defaults write com.apple.CrashReporter DialogType none

    # Set number of recent items (Applications, Document, Servers)
    # for category in 'applications' 'documents' 'servers'; do
    #   /usr/bin/osascript -e "tell application \"System Events\" to tell appearance preferences to set recent $category limit to 10"
    # done
  '';
}