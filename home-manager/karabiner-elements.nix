{ config, pkgs, lib, inputs, ... }: {
  xdg.configFile."karabiner/assets/complex_modifications/disable_cmd_tab.json" = {
    text = ''
{
  "title": "Disable Cmd+Tab (App Switcher)",
  "rules": [
    {
      "description": "Disable Command+Tab (prevent App Switcher)",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": "tab",
            "modifiers": {
              "mandatory": ["command"],
              "optional": ["any"]
            }
          },
          "to": [
            {
              "shell_command": "open 'raycast://extensions/raycast/navigation/switch-windows'"
            }
          ]
        },
        {
          "type": "basic",
          "from": {
            "key_code": "tab",
            "modifiers": {
              "mandatory": ["command", "shift"],
              "optional": ["any"]
            }
          },
          "to": [
            {
              "shell_command": "open 'raycast://extensions/raycast/navigation/switch-windows'"
            }
          ]
        }
      ]
    }
  ]
}
    '';
  };

}

