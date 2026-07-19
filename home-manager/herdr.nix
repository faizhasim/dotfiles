{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.lib.stylix.colors) withHashtag;

  herdrConfig = pkgs.writeText "herdr-config.toml" ''
    [keys]
    prefix = "ctrl+b"
    new_tab = "prefix+c"
    next_tab = "prefix+n"
    previous_tab = "prefix+p"
    switch_tab = "prefix+1..9"
    close_tab = "prefix+shift+x"
    rename_tab = "prefix+shift+t"
    focus_pane_left = "prefix+h"
    focus_pane_down = "prefix+j"
    focus_pane_up = "prefix+k"
    focus_pane_right = "prefix+l"
    zoom = "prefix+z"
    close_pane = "prefix+x"
    split_vertical = "prefix+v"
    split_horizontal = "prefix+minus"
    swap_pane_left = "prefix+shift+h"
    swap_pane_down = "prefix+shift+j"
    swap_pane_up = "prefix+shift+k"
    swap_pane_right = "prefix+shift+l"
    cycle_pane_next = "prefix+tab"
    cycle_pane_previous = "prefix+shift+tab"
    new_workspace = "prefix+shift+n"
    workspace_picker = "prefix+w"
    detach = "prefix+q"
    toggle_sidebar = "prefix+b"
    reload_config = "prefix+ctrl+r"
    goto = "prefix+g"
    copy_mode = "prefix+["

    [[keys.command]]
    key = "prefix+shift+g"
    type = "plugin_action"
    command = "worktrunk.open"
    description = "open worktree from default branch"

    [[keys.command]]
    key = "prefix+shift+c"
    type = "plugin_action"
    command = "worktrunk.open-current"
    description = "open worktree from current branch"

    [[keys.command]]
    key = "prefix+shift+d"
    type = "plugin_action"
    command = "worktrunk.remove"
    description = "remove worktree"

    [[keys.command]]
    key = "prefix+f"
    type = "plugin_action"
    command = "herdr-floax.toggle"
    description = "toggle floating shell"

    [[keys.command]]
    key = "prefix+alt+g"
    type = "popup"
    command = "zoxide query --list | fzf --height=40% --reverse --prompt='Select directory: ' | xargs -I{} sh -c 'cd \"{}\" && herdr workspace create --label \"$(basename \"{}\")\"'"
    description = "create workspace from zoxide"
    width = "80%"
    height = "60%"

    [theme]
    name = "nord"

    [theme.custom]
    accent = "${withHashtag.base0C}"
    panel_bg = "${withHashtag.base00}"

    [experimental]
    kitty_graphics = true

    [ui.sidebar.agents]
    row_gap = 0
    rows = [
      ["state_icon", "workspace", "tab"],
      ["agent", "state_text"]
    ]

    [ui.sidebar.spaces]
    row_gap = 0
    rows = [
      ["state_icon", "workspace"],
      ["branch", "git_status"]
    ]

    [ui.toast]
    delivery = "herdr"

    [ui.toast.herdr]
    position = "bottom-right"

    [worktrees]
    directory = "~/.herdr/worktrees"

    [terminal]
    default_shell = "zsh"
    shell_mode = "auto"
  '';
in
{
  home.file.".config/herdr/config.toml" = {
    source = herdrConfig;
    force = true;
  };
}
