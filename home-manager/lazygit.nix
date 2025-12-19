{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.lib.stylix) colors;
in
{
  programs.lazygit = {
    enable = true; # git tui
    enableZshIntegration = true;
    enableNushellIntegration = true;
    settings = {
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never --syntax-theme='Nord'";
          }
        ];
      };
      gui = {
        theme = {
          # Using stylix Nord base16 colors
          activeBorderColor = [
            "#${colors.base0D}" # base0D: blue
            "bold"
          ];
          inactiveBorderColor = [ "#${colors.base03}" ]; # base03: bright black
          searchingActiveBorderColor = [
            "#${colors.base0C}" # base0C: cyan
            "bold"
          ];
          optionsTextColor = [ "#${colors.base0D}" ]; # base0D: blue
          selectedLineBgColor = [ "#${colors.base02}" ]; # base02: selection background
          inactiveViewSelectedLineBgColor = [ "bold" ];
          cherryPickedCommitFgColor = [ "#${colors.base0D}" ]; # base0D: blue
          cherryPickedCommitBgColor = [ "#${colors.base0C}" ]; # base0C: cyan
          markedBaseCommitFgColor = [ "#${colors.base0D}" ]; # base0D: blue
          markedBaseCommitBgColor = [ "#${colors.base0A}" ]; # base0A: yellow
          unstagedChangesColor = [ "#${colors.base08}" ]; # base08: red
          defaultFgColor = [ "#${colors.base05}" ]; # base05: default foreground
        };
      };
    };
  };
}
