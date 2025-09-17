{ pkgs, hostname, ... }: {
  imports = [
    ./os
    ./homebrew
    ./stylix.nix
  ];

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = { zsh.enable = true; };

  launchd.user.agents.aerospace = {
    command = "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/aerospace.log";
      StandardErrorPath = "/tmp/aerospace.err.log";
    };
  };

}

