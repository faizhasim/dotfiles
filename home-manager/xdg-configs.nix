{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
{
  xdg.configFile."opencode/opencode.jsonc".source = ./opencode/opencode.jsonc;
  xdg.configFile."opencode/agent".source = ./opencode/agent;
  xdg.configFile."opencode/prompts".source = ./opencode/prompts;
}
