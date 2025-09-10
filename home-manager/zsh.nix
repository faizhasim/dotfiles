{ config, pkgs, lib, inputs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true; # ignore commands starting with a space
      save = 20000;
      size = 20000;
      share = true;
    };

    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
    ];

    # Use the 1Password Shell Plugins
#    shellPlugins = inputs._1password-shell-plugins.packages.${pkgs.system}.zshPlugins;

    shellAliases = {
       l = "ls -lA";
       g = "git";
       n = "nvim";
       v = "nvim";
       c = "clear";
       s = "sudo";
       b = "bat";

       gst = "g st";
       gco = "g co";
       ggpush = "g ps";

       cat = "bat";
       top = "btop";
       htop = "btop";
       diff = "delta";
       ssh = "TERM=screen ssh";
       python = "python3";
       pip = "python3 -m pip";
       vi = "nvim";
       vim = "nvim";

       npm = "op run --env-file=$HOME/.config/op-env/npm-env -- npm";
       pnpm = "op run --env-file=$HOME/.config/op-env/npm-env -- pnpm";
       yarn = "op run --env-file=$HOME/.config/op-env/npm-env -- yarn";
     };

     initContent = ''
       [ -f ~/.env/env.sh ] && source ~/.env/env.sh

       # export GIT_CONFIG_GLOBAL="$HOME/.config/git/mutable-config"

       # used for homebrew
       export XDG_DATA_DIRS=$XDG_DATA_DIRS:/opt/homebrew/share

       # better kubectl diff
       export KUBECTL_EXTERNAL_DIFF="${pkgs.dyff}/bin/dyff between --omit-header --set-exit-code"

       # asdf slows down my terminal start a lot
       #source ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh

       # bindkey '^w' edit-command-line
       # bindkey '^ ' autosuggest-accept
       # bindkey '^p' history-search-backward
       # bindkey '^n' history-search-forward
       # bindkey '^f' fzf-file-widget

       function cd() {
         builtin cd $*
         lsd
       }

       function mkd() {
         mkdir $1
         builtin cd $1
       }

       function awsauth { /opt/homebrew/opt/awsauth/bin/auth.sh "$@"; [[ -r "$HOME/.aws/sessiontoken" ]] && . "$HOME/.aws/sessiontoken"; }
     '';
  };
}
