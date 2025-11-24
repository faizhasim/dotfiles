{ config, pkgs, ... }:
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

    "zellij/config.kdl".source = ./zellij/config.kdl;
    "zellij/plugins/zellij-choose-tree.wasm".source = zellij-choose-tree;
    "zellij/plugins/zellij-sessionizer.wasm".source = zellij-sessionizer;

    "zellij/layouts/default.kdl".text = ''
      layout {
          default_tab_template {
              pane size=1 borderless=true {
                  plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {

                      format_left   "{mode}#[bg=#${colors.base00}] {tabs}"
                      format_center ""
                      format_right  "#[bg=#${colors.base00},fg=#${colors.base0D}]#[bg=#${colors.base0D},fg=#${colors.base01},bold] #[bg=#${colors.base02},fg=#${colors.base05},bold] {session} #[bg=#${colors.base03},fg=#${colors.base05},bold]"
                      format_space  ""
                      format_hide_on_overlength "true"
                      format_precedence "crl"

                      border_enabled  "false"
                      border_char     "─"
                      border_format   "#[fg=#6C7086]{char}"
                      border_position "top"

                      hide_frame_for_single_pane "true"

                      mode_normal        "#[bg=#${colors.base0B},fg=#${colors.base02},bold] NORMAL#[fg=#${colors.base0B}]"
                      mode_locked        "#[bg=#${colors.base04},fg=#${colors.base02},bold] LOCKED #[fg=#${colors.base04}]"
                      mode_resize        "#[bg=#${colors.base08},fg=#${colors.base02},bold] RESIZE#[fg=#${colors.base08}]"
                      mode_pane          "#[bg=#${colors.base0D},fg=#${colors.base02},bold] PANE#[fg=#${colors.base0D}]"
                      mode_tab           "#[bg=#${colors.base07},fg=#${colors.base02},bold] TAB#[fg=#${colors.base07}]"
                      mode_scroll        "#[bg=#${colors.base0A},fg=#${colors.base02},bold] SCROLL#[fg=#${colors.base0A}]"
                      mode_enter_search  "#[bg=#${colors.base0D},fg=#${colors.base02},bold] ENT-SEARCH#[fg=#${colors.base0D}]"
                      mode_search        "#[bg=#${colors.base0D},fg=#${colors.base02},bold] SEARCHARCH#[fg=#${colors.base0D}]"
                      mode_rename_tab    "#[bg=#${colors.base07},fg=#${colors.base02},bold] RENAME-TAB#[fg=#${colors.base07}]"
                      mode_rename_pane   "#[bg=#${colors.base0D},fg=#${colors.base02},bold] RENAME-PANE#[fg=#${colors.base0D}]"
                      mode_session       "#[bg=#${colors.base0E},fg=#${colors.base02},bold] SESSION#[fg=#${colors.base0E}]"
                      mode_move          "#[bg=#${colors.base0F},fg=#${colors.base02},bold] MOVE#[fg=#${colors.base0F}]"
                      mode_prompt        "#[bg=#${colors.base0D},fg=#${colors.base02},bold] PROMPT#[fg=#${colors.base0D}]"
                      mode_tmux          "#[bg=#${colors.base09},fg=#${colors.base02},bold] TMUX#[fg=#${colors.base09}]"

                      tab_normal              "#[fg=#${colors.base0D}]#[bg=#${colors.base0D},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{floating_indicator}#[fg=#${colors.base02},bold]"
                      tab_normal_fullscreen   "#[fg=#${colors.base0D}]#[bg=#${colors.base0D},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{fullscreen_indicator}#[fg=#${colors.base02},bold]"
                      tab_normal_sync         "#[fg=#${colors.base0D}]#[bg=#${colors.base0D},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{sync_indicator}#[fg=#${colors.base02},bold]"

                      tab_active              "#[fg=#${colors.base09}]#[bg=#${colors.base09},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{floating_indicator}#[fg=#${colors.base02},bold]"
                      tab_active_fullscreen   "#[fg=#${colors.base09}]#[bg=#${colors.base09},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{fullscreen_indicator}#[fg=#${colors.base02},bold]"
                      tab_active_sync         "#[fg=#${colors.base09}]#[bg=#${colors.base09},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{sync_indicator}#[fg=#${colors.base02},bold]"

                      tab_separator           "#[bg=#${colors.base00}] "

                      tab_sync_indicator       "  "
                      tab_fullscreen_indicator " 󰊓"
                      tab_floating_indicator   " 󰹙"

                      datetime        "#[fg=#6C7086,bold] {format} "
                      datetime_format "%a %Y-%m-%d %H:%M"
                      datetime_timezone "Asia/Kuala_Lumpur"

                  }
              }
              children
              pane size=1 borderless=true {
                  plugin location="status-bar" {
                      classic false
                  }
              }
          }
      }'';
  };
}
