{ config, pkgs, lib, inputs, username, ... }: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.direnv;
    mise = {
      enable = true;
      package = pkgs.mise;
    };
  };

  # Install direnv-1password library
  xdg.configFile."direnv/lib/1password.sh".source = "${inputs.direnv-1password}/1password.sh";
}
