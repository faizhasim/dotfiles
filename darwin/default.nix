{ pkgs, ... }:
{
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

  # Enable zsh as the default shell, but let home-manager manage it in ./home-manager/zsh.nix
  programs.zsh.enable = true;

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
