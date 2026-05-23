{ config, pkgs, ... }:

{
  # ── Keyboard Settings ──────────────────────────────────────────

  system.defaults.NSGlobalDomain = {
    # Disable press-and-hold for keys in favor of key repeat
    ApplePressAndHoldEnabled = false;

    # Key repeat rate (1 = fastest; minimum 1)
    KeyRepeat = 1;

    # Delay until repeat starts in ms (20 = shortest)
    InitialKeyRepeat = 20;

    # Disable auto-correction globally
    NSAutomaticSpellingCorrectionEnabled = false;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;

    # Full Keyboard Access — Tab can focus all controls, not just text boxes
    AppleKeyboardUIMode = 3;

    # Trackpad tracking speed (2.0 = moderately fast; range 0.0-3.0)
    "com.apple.trackpad.scaling" = 2.0;
  };

  system.activationScripts.keyboardSettings.text = ''
    # Set Double and Single quotes — using simpler format to avoid quote escaping issues
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

    echo "Disabling autocorrect in Safari, Mail, Notes…"

    # Safari
    defaults write com.apple.Safari NSAutomaticSpellingCorrectionEnabled -bool false

    # Mail
    defaults write com.apple.mail NSAutomaticSpellingCorrectionEnabled -bool false
    defaults write com.apple.mail NSAllowContinuousSpellChecking -bool false

    # Notes
    defaults write com.apple.Notes NSAutomaticSpellingCorrectionEnabled -bool false
  '';

  # ── Trackpad Settings ──────────────────────────────────────────

  system.defaults = {
    trackpad = {
      Clicking = true; # Tap-to-click
      TrackpadThreeFingerDrag = true; # Three-finger drag
      TrackpadRightClick = true; # Secondary click (right-click)
    };
    # Mouse tracking speed — not exposed as native nix-darwin option
    CustomUserPreferences = {
      NSGlobalDomain = {
        "com.apple.mouse.scaling" = 4.0;
      };
    };
  };

  system.activationScripts.trackpadSettings.text = ''
    # Tap to click (user + login screen)
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Force Click and haptic feedback
    defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool true
    defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool false
    defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -bool true

    # Silent clicking (0 = lightest haptic)
    defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0

    # Haptic feedback thresholds (0 = Light)
    defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
    defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0

    # Disable swipe between pages
    defaults write AppleEnableSwipeNavigateWithScrolls -bool false
  '';
}
