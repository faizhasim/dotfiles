{ config, pkgs, lib, inputs, ... }: {
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      package = pkgs.gitAndTools.delta;
    };
    userName = "Mohd Faiz Hasim";
    userEmail = "faizhasim@gmail.com";
    signing = {
      format = "ssh"; # use ssh key for signing
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/s3sNn/QYPJ+EbXhIbN1jqreE/GX/HU9l6z2f/siTI";
      signByDefault = true;
      signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };

    aliases = {
      cm = "commit";
      ca = "commit --amend --no-edit";
      co = "checkout";
      si = "switch";
      cp = "cherry-pick";

      di = "diff";
      dh = "diff HEAD";

      pu = "pull";
      ps = "push";
      pf = "push --force-with-lease";

      st = "status -sb";
      fe = "fetch";
      gr = "grep -in";

      ri = "rebase -i";
      rc = "rebase --continue";
    };
    ignores = [
      # ide
      ".idea"
      ".vs"
      ".vsc"
      ".vscode"
      # npm
      "node_modules"
      "npm-debug.log"
      # python
      "__pycache__"
      "*.pyc"

      ".ipynb_checkpoints" # jupyter
      "__sapper__" # svelte
      ".DS_Store" # mac
      "kls_database.db" # kotlin lsp

      "._*" # my own
    ];
    extraConfig = {
      init.defaultBranch = "main";
      pull = {
        ff = false;
        commit = false;
        rebase = true;
      };
      fetch.prune = true;
      push.autoSetupRemote = true;
      delta.line-numbers = true;
    };
  };
}
