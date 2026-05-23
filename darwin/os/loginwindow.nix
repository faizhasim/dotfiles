{ config, pkgs, ... }:

{
  # ── Screensaver Settings ───────────────────────────────────────
  # NOTE: askForPasswordDelay may not work on macOS 14+ (nix-darwin#908)

  system.defaults.screensaver = {
    # Require password to unlock screen saver
    askForPassword = true;

    # Grace period before password is required (0 = immediately)
    askForPasswordDelay = 0;
  };

  # ── Login Window Settings ──────────────────────────────────────

  system.defaults.loginwindow = {
    # Show name and password fields (not user list)
    SHOWFULLNAME = false;

    # Disable guest login
    GuestEnabled = false;
  };

  # Remaining login settings without native nix-darwin support
  system.activationScripts.loginwindowSettings.text = ''
    # Belt-and-suspenders: delete auto-login user to prevent macOS resetting the pref
    sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null
  '';
}
