{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.git = {
    enable = true;
    signing = {
      format = "ssh"; # use ssh key for signing
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/s3sNn/QYPJ+EbXhIbN1jqreE/GX/HU9l6z2f/siTI";
      signByDefault = true;
      signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };

    includes = [
      {
        contents = {
          "url \"git@github.com:faizhasim/\"" = {
            insteadof = "https://github.com/faizhasim/";
          };
          "url \"git@github.com:SEEK-Jobs/\"" = {
            insteadof = "https://github.com/SEEK-Jobs/";
          };
        };
      }
    ];
    settings = {
      init.defaultBranch = "main";
      pull = {
        ff = false;
        commit = false;
        rebase = true;
      };
      fetch.prune = true;
      push.autoSetupRemote = true;
      delta.line-numbers = true;
      user = {
        name = "Mohd Faiz Hasim";
        email = "faizhasim@gmail.com";
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
    };
    lfs.enable = true;

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
      # jupyter
      ".ipynb_checkpoints"
      # svelte
      "__sapper__"
      # mac
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      ".Spotlight-V100"
      ".Trashes"
      ".fseventsd"
      ".TemporaryItems"
      ".DocumentRevisions-V100"
      ".apdisk"
      # kotlin lsp
      "kls_database.db"
      # vim/neovim
      "*.swp"
      "*.swo"
      # shell history
      ".history"
      # dotenv
      ".env"
      # my own
      "._*"
    ];
  };

  programs.delta = {
    enable = true;
    package = pkgs.delta;
    enableGitIntegration = true;
  };
}
