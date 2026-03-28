{ pkgs, ... }:
{
  imports = [
    ./os
    ./homebrew
    ./stylix.nix
    ./secrets.nix
  ];

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Allow WezTerm to set environment variables for remote pane integration
    etc."ssh/sshd_config.d/99-wezterm.conf".text = ''
      AcceptEnv WEZTERM_REMOTE_PANE WEZTERM_PANE WEZTERM_UNIX_SOCKET WEZTERM_SSH
    '';
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
