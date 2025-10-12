{ config, pkgs, lib, inputs, nord-dircolors, ... }: {
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile "${nord-dircolors}/src/dir_colors";
  };
}
