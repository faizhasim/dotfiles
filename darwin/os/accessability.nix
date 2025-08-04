{ config, pkgs, ... }:

{
  system.activationScripts.extraActivation.text = ''
    # Enable access for assistive devices
    echo -n 'a' | sudo tee /private/var/db/.AccessibilityAPIEnabled &>/dev/null
    sudo chmod 444 /private/var/db/.AccessibilityAPIEnabled

    # Enable Text to Speech
    defaults write com.apple.speech.synthesis.general.prefs SpokenUIUseSpeakingHotKeyFlag -bool true

    # Uncomment other speech and accessibility settings as needed
    # defaults write com.apple.speech.synthesis.general.prefs SpokenUIUseSpeakingHotKeyCombo -int 2101
    # defaults write com.apple.speech.voice.prefs VisibleIdentifiers '{ "com.apple.speech.synthesis.voice.Alex" = 1; }'
    # defaults write com.apple.speech.voice.prefs SelectedVoiceCreator -int 1835364215
    # defaults write com.apple.speech.voice.prefs SelectedVoiceID -int 201
    # defaults write com.apple.speech.voice.prefs SelectedVoiceName -string "Alex"

    # For voice rate data:
    # plutil -replace VoiceRateDataArray -json '[
    #   [
    #     1835364215,
    #     201,
    #     350
    #   ]
    # ]' ~/Library/Preferences/com.apple.speech.voice.prefs.plist
  '';

  # Only use properties that are directly supported by nix-darwin
  system.defaults = {
    # Accessibility settings that are natively supported by nix-darwin
    universalaccess = {
      # Uncomment to enable these accessibility features if needed
      # reduceTransparency = false;
      # increaseContrast = false;
    };
  };
}