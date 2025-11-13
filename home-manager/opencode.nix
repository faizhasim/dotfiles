{
  config,
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
{
  xdg.configFile = {
    "opencode/opencode.jsonc".source = ./opencode/opencode.jsonc;
    "opencode/agent".source = ./opencode/agent;
    "opencode/prompts".source = ./opencode/prompts;
  };
}
