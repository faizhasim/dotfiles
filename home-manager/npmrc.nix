{ config, pkgs, lib, inputs, ... }: {
  home.file = {
    # npm, pnpm, yarn are aliased to run with 1Password environment in zsh.nix
    # see https://developer.1password.com/docs/cli/shell-plugins/
    # also see https://blog.1password.com/1password-cli-2_0/
    ".npmrc".text = ''
      init.author.name=Mohd Faiz Hasim
      init.author.email=faizhasim@gmail.com
      init.author.url=http://www.faizhasim.com
      @seek:registry=https://npm.cloudsmith.io/seek/npm/
      //npm.cloudsmith.io/seek/npm/:_authToken=''${CLOUDSMITH_AUTH_TOKEN}
    '';

    ".config/op-env/npm-env".text = ''
      CLOUDSMITH_AUTH_TOKEN="op://personal/cloudsmith/CLOUDSMITH_AUTH_TOKEN"
    '';
  };
}
