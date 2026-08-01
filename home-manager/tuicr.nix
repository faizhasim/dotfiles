# tuicr configuration using the external TOML file pattern
# (same as worktrunk/config.toml — external file for easier editing and version control)
# See: https://github.com/agavra/tuicr/blob/main/docs/CONFIG.md
_: {
  # tuicr is installed via home-manager/packages/common.nix
  # This module only manages the configuration file

  # Link external TOML config to XDG config directory
  xdg.configFile."tuicr/config.toml".source = ./tuicr/config.toml;
}
