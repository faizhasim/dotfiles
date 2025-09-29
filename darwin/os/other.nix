{ config, pkgs, ... }:

{
  security.pam.services.sudo_local.touchIdAuth = true;

  # Settings directly supported by nix-darwin
  system.defaults = {
    universalaccess = {
      # FIXME: cannot write universal access
      # reduceMotion = true;
      # reduceTransparency = true;
    };
    NSGlobalDomain = {
      # Increase window resize speed for Cocoa applications
      NSWindowResizeTime = 0.001;

      # Expand save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # Optional settings (uncomment if needed)
      # QLPanelAnimationDuration = 0;  # Opening and closing speed of Quick Look windows
      NSAutomaticWindowAnimationsEnabled = false;  # Opening and closing window animations
      # NSUseAnimatedFocusRing = false;  # Disable animated focus ring
      # NSTextShowsControlCharacters = true;  # Display ASCII control characters using caret notation
      # NSQuitAlwaysKeepsWindows = false;  # Disable Resume system-wide
      # NSDisableAutomaticTermination = true;  # Disable automatic termination of inactive apps
      # NSScrollViewRubberbanding = false;  # Disable rubber-band scrolling
      # NSAppSleepDisabled = true;  # Disable App Nap (not recommended)
    };
    CustomUserPreferences."org.hammerspoon.Hammerspoon".MJConfigFile = "${config.users.users.faizhasim.home}/.config/hammerspoon/init.lua";

  };

  # For settings that need system-level permissions or aren't directly supported
  system.activationScripts.otherSettings.text = ''
    # Menu bar icons configuration
    defaults -currentHost write dontAutoLoad -array \
      "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
      "/System/Library/CoreServices/Menu Extras/Volume.menu" \
      "/System/Library/CoreServices/Menu Extras/User.menu"

    defaults write com.apple.systemuiserver menuExtras -array \
      "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
      "/System/Library/CoreServices/Menu Extras/VPN.menu" \
      "/System/Library/CoreServices/Menu Extras/Displays.menu" \
      "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
      "/System/Library/CoreServices/Menu Extras/Battery.menu" \
      "/System/Library/CoreServices/Menu Extras/Clock.menu"

    # Reveal hostname info when clicking login window clock
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

    # Camera connection action
    defaults -currentHost write com.apple.ImageCapture2 HotPlugActionPath -string ""

    # Create symbolic links for hidden items

    # Link hidden prefPanes
    sudo ln -sf "/System/Library/CoreServices/Applications/Archive Utility.app/Contents/Resources/Archives.prefPane" "/Library/PreferencePanes/Archives.prefPane"

    # Link hidden command line tools
    sudo ln -sf "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport" "/usr/local/bin/airport"
    sudo ln -sf "/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc" "/usr/local/bin/jsc"

    # Link hidden fonts
    sudo ln -sf "/System/Library/PrivateFrameworks/CoreRecognition.framework/Resources/Fonts/" "/Library/Fonts/CoreRecognition"

    # Enable locate command and build locate database
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist

    # Remove duplicates in the "Open With" menu
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
  '';
}
