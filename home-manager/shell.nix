{ config, pkgs, lib, inputs, ... }: {
 programs = {
    nushell.enable = true; # zsh alternative
    zoxide.enable = true; # autojump
    jq.enable = true; # json parser
    bat.enable = true; # pretty cat
    lazygit.enable = true; # git tui
    yazi.enable = true; # file browser
    btop.enable = true; # htop alternative
    broot.enable = true; # browser big folders
    carapace.enable = true; # autocompletion
    carapace.enableNushellIntegration = true;

    # sqlite browser history
    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        inline_height = 20;
        style = "compact";
      };
    };

    # pretty prompt
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red)";
        };
      };
    };

    # pretty ls
    lsd = {
      enable = true;
      enableZshIntegration = true;
    };

    go = {
      enable = true;
      goPath = "go";
      goBin = "go/bin";
      goPrivate = [ ];
    };

    htop = {
      enable = true;
      settings = {
        tree_view = true;
        show_cpu_frequency = true;
        show_cpu_usage = true;
        show_program_path = false;
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand =
        "fd --type f --hidden --follow --exclude .git --exclude .vim --exclude .cache --exclude vendor --exclude node_modules";
      defaultOptions = [
        "--border sharp"
        "--inline-info"
      ];
    };

    # snippet manager
    pet = {
      enable = true;
      # <param=default-value> -> use variables
      snippets = [
        {
          command = "git rev-parse --short HEAD";
          description = "show short git rev";
          output = "888c0f8";
          tag = [ "git" ];
        }
        {
          description = "show size of a folder";
          command = "du -hs <folder>";
        }
        {
          description = "garden kubeconfig from ske-ci ondemand cluster";
          command =
            "kubectl get secret garden-kubeconfig-for-admin -n garden -o jsonpath='{.data.kubeconfig}' | base64 -d > garden-kubeconfig-for-admin.yaml";
        }
        {
          description = "get all images used in a kubernetes cluster";
          command =
            "kubectl get pods --all-namespaces -o jsonpath=\"{.items[*].spec['initContainers', 'containers'][*].image}\" | tr -s '[[:space:]]' '\n' | sort | uniq -c";
        }
      ];
    };

  };

}