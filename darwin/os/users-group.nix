{ config, pkgs, ... }:

{
  # Remaining settings without native nix-darwin support
  system.activationScripts.usersGroupsSettings.text = ''
    # Belt-and-suspenders: delete auto-login user to prevent macOS resetting the pref
    sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null
  '';
}
