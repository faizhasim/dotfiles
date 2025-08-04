{ config, pkgs, ... }:

{
  # Keyboard settings directly supported by nix-darwin
  system.defaults.NSGlobalDomain = {
    # Disable press-and-hold for keys in favor of key repeat
    ApplePressAndHoldEnabled = false;

    # Set key repeat rate (minimum 1)
    KeyRepeat = 1;

    # Set delay until repeat (in milliseconds)
    InitialKeyRepeat = 20;

    # Text substitution settings
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;

    # Optional settings (uncomment if needed)
     AppleKeyboardUIMode = 3;  # Full Keyboard Access - all controls
    # "com.apple.keyboard.fnState" = false;  # Use F1, F2, etc. as standard function keys
    # NSAutomaticPeriodSubstitutionEnabled = false;  # Disable automatic period substitution
    # NSAutomaticCapitalizationEnabled = false;  # Disable automatic capitalization
    # NSAllowContinuousSpellChecking = false;  # Disable continuous spell checking
  };

  # For settings that need system-level permissions or aren't directly supported
  system.activationScripts.keyboardSettings.text = ''
    # Set Double and Single quotes - using simpler format to avoid quote escaping issues
    defaults write NSGlobalDomain NSUserQuotesArray -array '\"' '\"' "'" "'"

    # Adjust keyboard brightness in low light
    defaults write com.apple.BezelServices kDim -bool true
    sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Keyboard Enabled" -bool true

    # Dim keyboard after idle time (in seconds)
    defaults write com.apple.BezelServices kDimTime -int 300
    sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Keyboard Dim Time" -int 300

    # Dictation Settings
    defaults write com.apple.assistant.support "Dictation Enabled" -bool true
    defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationIMMasterDictationEnabled -bool true
    defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationIMIntroMessagePresented -bool true

    # Use Enhanced Dictation if available
    if [ -d '/System/Library/Speech/Recognizers/SpeechRecognitionCoreLanguages/en_US.SpeechRecognition' ]; then
      defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationIMPresentedOfflineUpgradeSuggestion -bool true
      defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationIMSIFolderWasUpdated -bool true
      defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationIMUseOnlyOfflineDictation -bool true
    fi
  '';
}