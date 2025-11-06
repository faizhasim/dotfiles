{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
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
      k = "kubectl";

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

      gh = "op plugin run -- gh";
    };

    profileExtra = ''
      eval $(/opt/homebrew/bin/brew shellenv)
    '';

    initContent = ''
      autoload -U compinit
      compinit

      [ -f ~/.env/env.sh ] && source ~/.env/env.sh

      # used for homebrew
      export XDG_DATA_DIRS=$XDG_DATA_DIRS:/opt/homebrew/share

      # better kubectl diff
      export KUBECTL_EXTERNAL_DIFF="${pkgs.dyff}/bin/dyff between --omit-header --set-exit-code"

      # bindkey '^w' edit-command-line
      # bindkey '^ ' autosuggest-accept
      # bindkey '^p' history-search-backward
      # bindkey '^n' history-search-forward
      bindkey '^f' fzf-file-widget

      function cd() {
        builtin cd $*
        lsd
      }

      function mkd() {
        mkdir $1
        builtin cd $1
      }

      function awsp() {
        export AWS_PROFILE=$(aws configure list-profiles | fzf)
      }

      export PNPM_HOME="$HOME/.local/share/pnpm"
      export PATH="$PNPM_HOME:$PATH"

      eval "$(${pkgs.k3d}/bin/k3d completion zsh)"
      eval "$(${pkgs.saml2aws}/bin/saml2aws --completion-script-zsh)"

      [ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins..sh"

    '';
  };
}
