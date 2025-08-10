{ config, pkgs, lib, inputs, ... }: {
  imports = [
    inputs.nix4nvchad.homeManagerModule
  ];
  programs.nvchad.enable = true;
}