{ config, pkgs, lib, ... }:
{
  # rustup manages cargo/rustc; only add cargo bin to PATH and config via env
  home.sessionPath = lib.mkAfter [ "$HOME/.cargo/bin" ];

  # Cargo config for aarch64-apple-darwin linker
  home.file.".cargo/config.toml".text = ''
    [target.aarch64-apple-darwin]
    linker = "clang"
  '';
}
