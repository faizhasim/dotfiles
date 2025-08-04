{ config, pkgs, ... }:

{
  # For notification settings
  system.activationScripts.notificationSettings.text = ''
    # Set notification banner on screen time to 2 seconds (default is 5)
    defaults write com.apple.notificationcenterui bannerTime 2

    # Optional: Disable Notification Center and remove menu bar icon
    # launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null
  '';
}