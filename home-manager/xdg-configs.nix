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
}
