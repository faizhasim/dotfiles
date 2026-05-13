{
  pkgs,
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

      # Zellij socket dir - macOS TMPDIR is too long for session names >22 chars
      # Max socket path is 103 bytes, macOS TMPDIR can be ~50+ bytes
      export ZELLIJ_SOCKET_DIR="$HOME/.cache/zellij/sockets"
      mkdir -p "$ZELLIJ_SOCKET_DIR"

      # Per-project opencode overrides (merged on top of global config)
      # Place private/company-specific MCPs here, outside the dotfiles repo
      local opencode_overrides="$HOME/.config/opencode/opencode-overrides.json"
      [[ -f "$opencode_overrides" ]] && export OPENCODE_CONFIG="$opencode_overrides"
    '';

    initContent = ''
      # Uncomment next two lines to profile startup: zmodload zsh/zprof ... zprof
      # zmodload zsh/zprof

      # Cache completions; only regenerate if .zcompdump is older than 24h
      autoload -Uz compinit
      local zcompdump="$ZDOTDIR/.zcompdump"
      if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
        compinit
      else
        compinit -C
      fi

      [ -f ~/.env/env.sh ] && source ~/.env/env.sh

      # used for homebrew
      export XDG_DATA_DIRS=$XDG_DATA_DIRS:/opt/homebrew/share

      # bindkey '^w' edit-command-line
      # bindkey '^ ' autosuggest-accept
      # bindkey '^p' history-search-backward
      # bindkey '^n' history-search-forward
      bindkey '^f' fzf-file-widget

      # Zellij session picker widget (Ctrl-b s)
      zellij-session-picker() {
        local session
        session=$(zellij list-sessions -s 2>/dev/null | fzf --height=40% --reverse --prompt="Select Zellij session: ")
        if [[ -n "$session" ]]; then
          BUFFER="zellij attach \"$session\""
          zle accept-line
        fi
        zle reset-prompt
      }
      zle -N zellij-session-picker

      # Zellij session from zoxide (Ctrl-b g)
      zellij-session-from-zoxide() {
        local dir session_name
        dir=$(zoxide query --list 2>/dev/null | fzf --height=40% --reverse --prompt="Select directory: ")
        if [[ -n "$dir" ]]; then
          session_name=$(basename "$dir")
          BUFFER="cd \"$dir\" && zellij attach --create \"$session_name\""
          zle accept-line
        fi
        zle reset-prompt
      }
      zle -N zellij-session-from-zoxide

      # Prefix key handler for Ctrl-b
      tmux-prefix() {
        local key
        read -sk key
        case "$key" in
          s) zle zellij-session-picker ;;
          g) zle zellij-session-from-zoxide ;;
        esac
      }
      zle -N tmux-prefix
      bindkey '^b' tmux-prefix

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

      [ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh
      [ -f ~/.config/zsh/extras.sh ] && source ~/.config/zsh/extras.sh

      # Cache mise activation (saves ~100ms per shell start)
      # Invalidated when .zshenv home-manager symlink changes (i.e., any rebuild)
      local mise_cache="$HOME/.cache/mise/mise-activate.zsh"
      local mise_bin="${pkgs.mise}/bin/mise"
      local zshenv="$HOME/.zshenv"
      if [[ ! -f "$mise_cache" || "$zshenv" -nt "$mise_cache" || "$mise_bin" -nt "$mise_cache" ]]; then
        mkdir -p "$(dirname "$mise_cache")"
        "$mise_bin" activate zsh > "$mise_cache"
      fi
      source "$mise_cache"

      # IMPORTANT: Add proto/bin AFTER mise activation
      # mise resets PATH, so we must add proto after it runs
      # export PATH="$HOME/.proto/bin:$PATH"
      # eval "$(proto activate zsh)"

      # zprof
    '';
  };
}
