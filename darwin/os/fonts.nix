{ config, pkgs, ... }:

{
  fonts = {
      packages = with pkgs; [
        dejavu_fonts
        font-awesome
        hack-font
        meslo-lgs-nf
        noto-fonts
        noto-fonts-emoji
        sketchybar-app-font
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.hack
      ];
    };
}