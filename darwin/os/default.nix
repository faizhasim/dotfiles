{ pkgs, ... }:
{
  imports = [
    ./accessibility.nix
    ./app-store.nix
    ./displays.nix
    ./dock.nix
    ./finder.nix
    ./fonts.nix
    ./general.nix
    ./icloud.nix
    ./input-devices.nix
    ./language-region.nix
    ./loginwindow.nix
    ./network.nix
    ./notifications.nix
    ./pbs.nix
    ./printer.nix
    ./security-privacy.nix
    ./siri.nix
    ./sound.nix
    ./spotlight.nix
    ./utilities.nix
    ./users-group.nix
  ];
}
