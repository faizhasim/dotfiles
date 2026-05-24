_: {
  brews = [ "faizhasim/tele-kb-bot/tele-kb-bot" ];
  casks = [
    "discord"
    "google-chrome" # used for selenium and testing
    "obs" # stream / recoding software
    "steam" # gaming
  ];
  taps = [
    {
      name = "faizhasim/tele-kb-bot";
      clone_target = "https://github.com/faizhasim/tele-kb-bot.git";
      force_auto_update = true;
    }
  ];
}
