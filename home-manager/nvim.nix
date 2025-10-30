{ config, pkgs, lib, inputs, username, ... }: {
  # TIP: home.file.".config/nvim".source = ./nvim to store in nix store, for now I want to do a bit of experimentations
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${inputs.nvim}";
}
