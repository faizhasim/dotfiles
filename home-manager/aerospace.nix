{ config, pkgs, lib, inputs, user, ... }: {
 programs.aerospace = {
  enable = true;
  package = pkgs.aerospace;
  launchd = {
   enable = true;
   keepAlive = true;
  };
  userSettings = {
    after-startup-command = [
      "exec-and-forget /etc/profiles/per-user/${user}/bin/sketchybar --reload" # add reload flag
      "exec-and-forget /etc/profiles/per-user/${user}/bin/borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0"
    ];
    exec-on-workspace-change = [
      "/etc/profiles/per-user/${user}/bin/sketchybar"
      "--trigger"
      "aerospace_workspace_change"
    ];
    start-at-login = true;
    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;
    accordion-padding = 30;
    default-root-container-layout = "tiles";
    default-root-container-orientation = "auto";
    on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
    automatically-unhide-macos-hidden-apps = false;
    key-mapping.preset = "qwerty";

    gaps = {
      inner = {
        horizontal = 12;
        vertical = 12;
      };
      outer = {
        left = 12;
        bottom = 12;
        top = 32;
        right = 12;
      };
    };

    mode.main.binding = {
      alt-slash = "layout tiles horizontal vertical";
      alt-comma = "layout accordion horizontal vertical";

      alt-h = "focus left";
      alt-j = "focus down";
      alt-k = "focus up";
      alt-l = "focus right";

      alt-shift-h = "move left";
      alt-shift-j = "move down";
      alt-shift-k = "move up";
      alt-shift-l = "move right";

      alt-minus = "resize smart -50";
      alt-equal = "resize smart +50";

      alt-1 = "workspace 1";
      alt-2 = "workspace 2";
      alt-3 = "workspace 3";
      alt-4 = "workspace 4";
      alt-5 = "workspace 5";

      alt-shift-1 = "move-node-to-workspace 1";
      alt-shift-2 = "move-node-to-workspace 2";
      alt-shift-3 = "move-node-to-workspace 3";
      alt-shift-4 = "move-node-to-workspace 4";
      alt-shift-5 = "move-node-to-workspace 5";

      alt-tab = "workspace-back-and-forth";

      alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

      alt-shift-semicolon = "mode service";

      alt-shift-c = "reload-config";
    };

  };
 };
}
