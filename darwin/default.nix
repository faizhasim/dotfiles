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

}

