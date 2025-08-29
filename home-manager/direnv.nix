{ config, pkgs, lib, inputs, user, ... }: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.direnv;
    mise = {
      enable = true;
      package = pkgs.mise;
    };
  };
}
