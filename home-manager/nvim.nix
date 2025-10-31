{ config, pkgs, lib, inputs, username, ... }: {
  home.activation.nvimLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p  "$HOME/.config/nvim"
    stow -v -t "$HOME/.config/nvim" nvim/
  '';

}
