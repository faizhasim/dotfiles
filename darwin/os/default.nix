{ pkgs, ... }: {
  imports = [
    ./accessability.nix
    ./app-store.nix
    ./displays.nix
    ./dock.nix
    ./finder.nix
    ./fonts.nix
    ./general.nix
    ./icloud.nix
    ./keyboard.nix
    ./language-region.nix
    ./mission-control.nix
    ./network.nix
    ./notifications.nix
    ./other.nix
    ./pbs.nix
    ./printer.nix
    ./security-privacy.nix
    ./siri.nix
    ./sound.nix
    ./spotlight.nix
    ./trackpad.nix
    ./users-group.nix
  ];
}