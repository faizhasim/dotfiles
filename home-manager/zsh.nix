{ pkgs, lib, ... }:

let
  # Extract nix store hash for mise cache keying.
  # Store files have mtime=0, so -nt can't detect rebuilds; keying on hash avoids staleness.
  miseStorePath = "${pkgs.mise}";
  miseHash = builtins.elemAt (builtins.match "/nix/store/([a-z0-9]+)-.*" miseStorePath) 0;
  # Same approach for starship init caching
  starshipStorePath = "${pkgs.starship}";
  starshipHash = builtins.elemAt (builtins.match "/nix/store/([a-z0-9]+)-.*" starshipStorePath) 0;
in
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
      diff = "delta";
      top = "btop";
      htop = "btop";
      obsidian = "/Applications/Obsidian.app/Contents/MacOS/obsidian-cli";
      ssh = "TERM=screen ssh";
      python = "python3";
      pip = "python3 -m pip";
      vi = "nvim";
      vim = "nvim";

    };

    profileExtra = ''
      # Cache homebrew env — brew shellenv is a subprocess call (~60ms)
      local brew_cache="$HOME/.cache/homebrew/shellenv.zsh"
      if [[ ! -f "$brew_cache" || "/opt/homebrew/bin/brew" -nt "$brew_cache" ]]; then
        mkdir -p "$(dirname "$brew_cache")"
        /opt/homebrew/bin/brew shellenv > "$brew_cache"
      fi
      source "$brew_cache"

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

      # Skip compaudit — Nix store files are trusted (owned by root:nixbld).
      # compaudit stats every file in fpath checking ownership, costing ~233ms.
      export ZSH_DISABLE_COMPFIX=true

      # Cache completions; only regenerate if .zcompdump is older than 24h
      autoload -Uz compinit
      local zcompdump="$ZDOTDIR/.zcompdump"
      if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
        compinit
      else
        compinit -C
      fi

      [ -f ~/.env/env.sh ] && source ~/.env/env.sh

      # Re-source hm-session-vars when __HM_SESS_VARS_SOURCED is inherited
      # from parent process (e.g., zellij server). Without this, new zellij
      # panes never pick up changes to home.sessionVariables because the
      # guard prevents hm-session-vars.sh from running.
      # Fixes: QMD_FORCE_CPU, OP_ACCOUNT, and all home.sessionVariables
      if [[ -n "$__HM_SESS_VARS_SOURCED" && -f "$HOME/.zshenv" ]]; then
        unset __HM_SESS_VARS_SOURCED
        . "$HOME/.zshenv"
      fi

      # used for homebrew
      export XDG_DATA_DIRS=$XDG_DATA_DIRS:/opt/homebrew/share

      # bindkey '^w' edit-command-line
      # bindkey '^ ' autosuggest-accept
      # bindkey '^p' history-search-backward
      # bindkey '^n' history-search-forward

      # Lazy fzf — loads key bindings on first ^f press
      _lazy_fzf() {
        unfunction _lazy_fzf
        source <(${pkgs.fzf}/bin/fzf --zsh) 2>/dev/null
        zle fzf-file-widget
      }
      zle -N _lazy_fzf
      bindkey '^f' _lazy_fzf

      # Lazy atuin — loads shell integration on first Ctrl-R
      _lazy_atuin() {
        unfunction _lazy_atuin
        eval "$(${pkgs.atuin}/bin/atuin init zsh --disable-up-arrow)" 2>/dev/null
        zle atuin-search
      }
      zle -N _lazy_atuin
      bindkey '^r' _lazy_atuin

      # Lazy herdr completions — registers on first `herdr<TAB>`
      _herdr() {
        unfunction _herdr
        source <(herdr completion zsh) 2>/dev/null
        _herdr "$@"
      }
      compdef _herdr herdr

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
      # Only bind Ctrl-b prefix outside Herdr (for Zellij sessions).
      # Inside Herdr, Ctrl-b is the Herdr multiplexer prefix.
      if [[ -z "$HERDR_ENV" ]]; then
        bindkey '^b' tmux-prefix
      fi

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

      [ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh
      [ -f ~/.config/zsh/extras.sh ] && source ~/.config/zsh/extras.sh

      # Cache mise activation per store path (keyed by nix hash, not mtime).
      # Nix store files all have mtime=0, so -nt comparison can't detect rebuilds.
      # The hash in the filename changes when mise updates, avoiding staleness.
      local mise_bin="${pkgs.mise}/bin/mise"
      local mise_cache="$HOME/.cache/mise/mise-activate-${miseHash}.zsh"
      if [[ ! -f "$mise_cache" ]]; then
        mkdir -p "$(dirname "$mise_cache")"
        "$mise_bin" activate zsh > "$mise_cache"
      fi
      source "$mise_cache"

      # Cache starship prompt init — subprocess call is ~85ms
      if [[ $TERM != "dumb" ]]; then
        local starship_cache="$HOME/.cache/starship/init-${starshipHash}.zsh"
        if [[ ! -f "$starship_cache" ]]; then
          mkdir -p "$(dirname "$starship_cache")"
          "${pkgs.starship}/bin/starship" init zsh > "$starship_cache"
        fi
        source "$starship_cache"
      fi

      # Override mise precmd hook to skip hook-env calls when directory unchanged.
      # mise hook-env is ~160ms and runs on every other prompt by default.
      # After first setup in a directory, env is stable until cd — skip the binary call.
      _mise_hook_precmd() {
        if [[ "$__MISE_ZSH_CHPWD_RAN" == "1" ]]; then
          export __MISE_ZSH_CHPWD_RAN=0
          return
        fi
        if [[ "$PWD" == "$__MISE_LAST_PWD" ]]; then
          return
        fi
        __MISE_LAST_PWD="$PWD"
        eval "$("$mise_bin" hook-env -s zsh --reason precmd)"
      }
      # Initialise PWD tracker so first prompt also skips mise hook-env
      # when starting in the same directory (common case: shells open in ~).
      export __MISE_LAST_PWD="$PWD"

      # Tell pnpm where to store global packages.
      # On macOS the default is ~/Library/pnpm, but our existing global binaries
      # (copilot, markdown-toc, tsc, etc.) live in ~/.local/share/pnpm.
      # Setting this explicitly avoids the "not in PATH" warning and keeps new
      # global installs in the same place as the old ones.
      export PNPM_HOME="$HOME/.local/share/pnpm"

      # Enable Corepack for pnpm (Corepack ships with Node.js, managed by mise)
      # This creates a shim that auto-resolves pnpm from package.json's packageManager field.
      # Marker-based to avoid re-running every shell start.
      local corepack_marker="$HOME/.cache/corepack/.pnpm-enabled"
      if [[ ! -f "$corepack_marker" ]]; then
        mkdir -p "$(dirname "$corepack_marker")"
        corepack enable pnpm 2>/dev/null && touch "$corepack_marker"
      fi

      # Pre-cache a default pnpm version for use outside project directories
      # (where no package.json/packageManager field exists)
      local global_pnpm_marker="$HOME/.cache/corepack/.global-pnpm-ready"
      if [[ ! -f "$global_pnpm_marker" ]]; then
        mkdir -p "$(dirname "$global_pnpm_marker")"
        corepack install --global pnpm@latest 2>/dev/null && touch "$global_pnpm_marker"
      fi

      # IMPORTANT: Add paths AFTER mise activation — mise resets PATH
      # pnpm v10 bins are in PNPM_HOME directly, v11+ uses PNPM_HOME/bin
      export PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH"

      # zprof
    '';
  };
}
