{ ... }:
{
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    exitShellOnExit = true;
  };
  xdg.configFile."zellij/config.kdl".source = ./zellij/config.kdl;
}
