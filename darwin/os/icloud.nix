{ config, pkgs, ... }:

{
  # iCloud settings directly supported by nix-darwin
  system.defaults.NSGlobalDomain = {
    # Save to iCloud by default
    NSDocumentSaveNewDocumentsToCloud = true;
  };
}