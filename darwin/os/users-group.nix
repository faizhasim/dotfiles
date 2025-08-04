{ config, pkgs, ... }:

{
  # All Users & Groups settings through activation script
  system.activationScripts.usersGroupsSettings.text = ''
    # Display login window as: Name and password (not full name)
    sudo defaults write /Library/Preferences/com.apple.loginwindow "SHOWFULLNAME" -bool false

    # Disable automatic login
    sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null

    # Disable guest login
    sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

    # Disable password hints (set count to 0)
    defaults write NSGlobalDomain RetriesUntilHint -int 0

    # Optional settings (uncomment if needed)
    # Show fast user switching menu as account name
    # defaults write NSGlobalDomain userMenuExtraStyle -int 1

    # Enable automatic login as current user
    # sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser -string "$(whoami)"
  '';
}