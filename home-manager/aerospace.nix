{ config, pkgs, lib, inputs, ... }: {
 programs.aerospace = {
  enable = true;
  package = pkgs.aerospace;
  launchd = {
   enable = true;
   keepAlive = true;
  };
#  userSettings = {
#
#  };
 };
}