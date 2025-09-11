{ pkgs, hostname, ... }: {
  imports = [
    ./os
    ./homebrew
  ];

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = { zsh.enable = true; };

}