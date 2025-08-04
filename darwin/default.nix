{ pkgs, ... }: {
  imports = [
    ./os
    ./homebrew.nix
  ];

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = { zsh.enable = true; };

#  services = {
#    # FIXME: driver issues
#    karabiner-elements.enable = false;
#    sketchybar = {
#      enable = false;
#      extraPackages = with pkgs; [ jq gh ];
#    };
#  };


}