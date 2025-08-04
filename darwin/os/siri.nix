{ config, pkgs, ... }:

{
  # Siri settings through activation script
  system.activationScripts.siriSettings.text = ''
    # Enable Siri
    defaults write com.apple.assistant.support "Assistant Enabled" -bool true
    
    # Set Siri language
    defaults write com.apple.assistant.backedup "Session Language" -string "en-US"
    
    # Disable keyboard shortcut for Siri (0 = Off)
    defaults write com.apple.Siri HotkeyTag -int 0
    
    # Show Siri in menu bar
    defaults write com.apple.Siri StatusMenuVisible -bool true
    
    # Optional settings (uncomment if needed)
    # Voice feedback (3 = Off)
    # defaults write com.apple.assistant.backedup "Use device speaker for TTS" -int 3
    
    # For customized keyboard shortcut
    # defaults write com.apple.Siri CustomizedKeyboardShortcut
  '';
}