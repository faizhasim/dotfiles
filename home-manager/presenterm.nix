# presenterm configuration
#
# presenterm does not have a home-manager module yet, so we manage the config file manually.
# The config file is located at ~/.config/presenterm/config.yaml
#
# Why these settings?
# -------------------
# - image_protocol: auto (default)
#   Let presenterm auto-detect the best protocol. Works well outside Zellij.
#   Inside Zellij, mermaid rendering may not work - use presenterm outside Zellij instead.
#
# - mermaid.scale: 3
#   Scaling factor for mermaid diagrams. Higher values = larger, sharper images.
#   Default is 2, we use 3 for better visibility on high-DPI displays.
#
# - snippet.render.threads: 4
#   Number of threads for async rendering of +render code blocks (mermaid, d2, etc.).
#   Default is 2, we use 4 for faster parallel rendering.
#
# References:
# - presenterm settings docs: https://mfontanini.github.io/presenterm/configuration/settings.html
# - Image protocols: https://mfontanini.github.io/presenterm/configuration/settings.html#preferred-image-protocol
{
  config,
  pkgs,
  lib,
  ...
}:
let
  configYaml = pkgs.writeText "presenterm-config.yaml" ''
    # Mermaid diagram configuration
    mermaid:
      # Scaling factor for mermaid diagrams (default: 2)
      # Higher = larger diagrams (better for utilizing screen space)
      scale: 3

    # Code snippet rendering configuration
    snippet:
      render:
        # Number of threads for async rendering (default: 2)
        threads: 4
  '';
in
{
  # presenterm is installed via home-manager/packages/common.nix (line 128)
  # This module only manages the configuration file

  xdg.configFile."presenterm/config.yaml".source = configYaml;
}
