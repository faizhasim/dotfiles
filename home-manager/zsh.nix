{
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

      gst = "git status -sb";
      gco = "git checkout";
      ggpush = "git push";

      cat = "bat";
      top = "btop";
      htop = "btop";
      diff = "delta";
      ssh = "TERM=screen ssh";
      python = "python3";
      pip = "python3 -m pip";
      vi = "nvim";
      vim = "nvim";

    };

    profileExtra = ''
      eval $(/opt/homebrew/bin/brew shellenv)
    '';

    initContent = ''
      if [[ -z "$ZELLIJ" ]]; then
          if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
              zellij attach -c
          else
              zellij -l welcome
          fi

          if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
              exit
          fi
      fi

      autoload -U compinit
      compinit

      [ -f ~/.env/env.sh ] && source ~/.env/env.sh

      # used for homebrew
      export XDG_DATA_DIRS=$XDG_DATA_DIRS:/opt/homebrew/share

      # bindkey '^w' edit-command-line
      # bindkey '^ ' autosuggest-accept
      # bindkey '^p' history-search-backward
      # bindkey '^n' history-search-forward
      bindkey '^f' fzf-file-widget

      cd() {
        builtin cd "$@"
        lsd
      }

      mkd() {
        mkdir "$1"
        builtin cd "$1"
      }

      awsp() {
        export AWS_PROFILE="$(aws configure list-profiles | fzf)"
      }

      npm() {
        op run --env-file="$HOME/.config/op-env/npm-env" -- npm "$@"
      }

      pnpm() {
        op run --env-file="$HOME/.config/op-env/npm-env" -- pnpm "$@"
      }

      yarn() {
        op run --env-file="$HOME/.config/op-env/npm-env" -- yarn "$@"
      }

      gh() {
        op plugin run -- gh "$@"
      }

      shellai() {
        local output=$(echo $(opencode run "This get invoked from CLI and strictly need to output valid ZSH compatible command that can be run on actual shell. It will predict the best command to be output to stdout based on the user prompt. For example: Prompt of 'list down all files in home directory' will ONLY output 'ls ~'. It will not call any opencode tools on 'write' mode. It will not execute, and hence, will not end with newline character. Please execute based on the following prompt: $1") | xargs)
        echo $output | pbcopy
        echo "Output command copied to clipboard: $output"
      }

      export PNPM_HOME="$HOME/.local/share/pnpm"
      export PATH="$PNPM_HOME:$PATH"

      [ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh
      [ -f ~/.config/zsh/extras.sh ] && source ~/.config/zsh/extras.sh

    '';
  };
}
