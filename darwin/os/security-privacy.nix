{ config, pkgs, ... }:

{
  # Security settings through activation script
  system.activationScripts.securitySettings.text = ''
    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -bool true
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    # Disable automatic login
    sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser &> /dev/null

    # Allow applications downloaded from anywhere
    sudo spctl --master-disable

    # Turn on Firewall
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

    # Allow signed apps
    sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool true

    # Firewall logging
    # sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -bool false

    # Stealth mode
    sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true

    # Disable Infared Remote
    sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false

    # Optional settings (uncomment if needed)
    # Disable the "Are you sure you want to open this application?" dialog
    # defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Disable encrypted swap (secure virtual memory)
    # sudo defaults write /Library/Preferences/com.apple.virtualMemory DisableEncryptedSwap -boolean yes

    # Disable automatic login when FileVault is enabled
    # sudo defaults write /Library/Preferences/com.apple.loginwindow DisableFDEAutoLogin -bool true

    # FileVault check and enable if needed
    if [[ $(sudo fdesetup status | head -1) == "FileVault is Off." ]]; then
      # Comment/uncomment based on your preference - this will prompt for password
      # sudo fdesetup enable -user "$(whoami)"
      echo "FileVault is off. Consider enabling it manually or uncommenting the line in the nix configuration."
    fi

    # Privacy settings through tccutil can be added here if needed
    # Requires SIP to be disabled
  '';

  # Optional: Configure additional system security settings
  security = {
    # Additional security settings if supported by nix-darwin
  };
}