{ ... }: {
  brews = [
      "seek-jobs/tools/awsauth"
      "seek-jobs/tools/gantry"
      # Automat formula relies on Github release (via gh auth), in which I couldn't make it work yet
      # "seek-jobs/tools/automat"
      # "seek-jobs/tools/automat@1.0.0-alpha.6"
    ];
    casks = [];
    taps = [
      {
        name = "SEEK-Jobs/tools"; # remove and re-apply after configuring git ssh if this won't work
        clone_target = "git@github.com:SEEK-Jobs/homebrew-tools.git";
        force_auto_update = true;
      }
    ];
}
