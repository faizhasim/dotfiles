{ config, pkgs, ... }:

{

  system.defaults.NSGlobalDomain = {
    # Play feedback when volume is changed
    "com.apple.sound.beep.feedback" = 0;
  };
  # Sound settings through activation script
  system.activationScripts.soundSettings.text = ''
    # Play user interface sound effects
    defaults write com.apple.systemsound com.apple.sound.uiaudio.enabled -bool false

    # Disable flashing the screen when an alert sound occurs
    defaults write NSGlobalDomain com.apple.sound.beep.flash -bool false

    # Alert volume (50%)
    defaults write NSGlobalDomain com.apple.sound.beep.volume -float 0.6065307
    
    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "
    
    # Optional: Set custom system alert sound
    # defaults write com.apple.systemsound com.apple.sound.beep.sound -string "/System/Library/Sounds/Blow.aiff"
  '';
}