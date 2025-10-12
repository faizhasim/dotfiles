
{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;

    profiles.default = {
      userSettings = {
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";

        # Language specific
        "[typescript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[javascript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[go]" = {
          "editor.defaultFormatter" = "golang.go";
        };
      };

      keybindings = [
        {
          key = "ctrl+shift+t";
          command = "workbench.action.terminal.new";
        }
      ];
    };
  };

  home.activation.ensureCodeCli =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.local/bin"
      ln -sf ${pkgs.vscode}/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code \
        "$HOME/.local/bin/code"
      echo "Linked VS Code CLI → $HOME/.local/bin/code"
    '';

  home.activation.installVscodeExtensions =
    lib.hm.dag.entryAfter [ "ensureCodeCli" ] ''
      PATH="$HOME/.local/bin:$PATH"
      echo "Ensuring VS Code extensions..."
      extensions=(
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        golang.go
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-vscode-remote.remote-containers
      )

      installed="$(code --list-extensions || true)"

      for ext in "''${extensions[@]}"; do
        if echo "$installed" | grep -q "^$ext$"; then
          echo "✓ $ext already installed"
        else
          echo "➜ Installing $ext"
          code --install-extension "$ext" || true
        fi
      done
    '';
}

