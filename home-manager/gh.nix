{ config, pkgs, lib, inputs, ... }: {
 programs.gh = {
  enable = true;
  gitCredentialHelper = {
    enable = true;
    hosts = [ "https://github.com" "https://gist.github.com" ];
  };
  package = pkgs.gh;
  settings = {
    editor = "nvim";
    git_protocol = "ssh";
  };
 };
}