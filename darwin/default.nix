{ pkgs, ... }:
{
  imports = [
    ./os
    ./homebrew
    ./stylix.nix
    ./activation.nix
  ];

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Allow WezTerm to set environment variables for remote pane integration
    # See: https://wezterm.org/ssh.html
    etc."ssh/sshd_config.d/99-wezterm.conf".text = ''
      AcceptEnv WEZTERM_REMOTE_PANE WEZTERM_PANE WEZTERM_UNIX_SOCKET WEZTERM_SSH COLORTERM TERM TERM_PROGRAM TERM_PROGRAM_VERSION
    '';
  };

  # Enable zsh as the default shell, but let home-manager manage it in ./home-manager/zsh.nix
  # Use pre-built nix-index database (from nix-index-database flake) instead of building locally
  programs.nix-index-database = {
    comma.enable = true;
  };

  programs.zsh.enable = true;
  # Disable system-wide completion init so home-manager can handle it with caching
  programs.zsh.enableCompletion = false;

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
