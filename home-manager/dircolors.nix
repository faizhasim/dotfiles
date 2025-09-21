{ config, pkgs, lib, inputs, nord-dircolors, ... }: {
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".dir_colors".source = "${nord-dircolors}/src/dir_colors";
}
