{
  config,
  pkgs,
  inputs,
  system,
  ...
}:
let
  inherit (config.lib.stylix) colors;

  zellij-choose-tree = pkgs.fetchurl {
    url = "https://github.com/laperlej/zellij-choose-tree/releases/latest/download/zellij-choose-tree.wasm";
    sha256 = "sha256-OGHLzCM9wg0CLm5SSr3bmElcciBIqamalQjgkTuzAeg=";
  };

  zellij-sessionizer = pkgs.fetchurl {
    url = "https://github.com/laperlej/zellij-sessionizer/releases/latest/download/zellij-sessionizer.wasm";
    sha256 = "sha256-AGuWbuRX7Yi9tPdZTzDKULXh3XLUs4navuieCimUgzQ=";
  };
in
{
  programs.zellij.enable = true;

  xdg.configFile = {
    # zellij/config.kdl is generated dynamically from repos.toml via activation script
    # see: darwin/activation.nix generateZellijConfig
    "zellij/plugins/zellij-choose-tree.wasm".source = zellij-choose-tree;
    "zellij/plugins/zellij-sessionizer.wasm".source = zellij-sessionizer;

    "zellij/layouts/default.kdl".text = ''
      layout {
          default_tab_template {
              pane size=1 borderless=true {
                  plugin location="compact-bar"
              }
              children
          }
      }'';
  };
}
