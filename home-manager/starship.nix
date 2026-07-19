{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{

  # pretty prompt
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = false; # Cached init in zsh.nix
    settings = {
      add_newline = true;

      format = lib.concatStrings [
        "[](base16)"
        "$os"
        "[](bg:base02 fg:base16)"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_status"
        "[](base02)"
        "$directory"
        "$cmd_duration"
        "$fill"
        "$c"
        "$rust"
        "$golang"
        "$nodejs"
        "$php"
        "$java"
        "$kotlin"
        "$haskell"
        "$python"
        "$aws"
        "[](fg:base02)"
        "$docker_context"
        "$conda"
        "$memory_usage"
        "$battery"
        "[](bg:base02 fg:base16)"
        "[](fg:base16)"
        "$time"
        "$line_break"
        "$character"
      ];

      os = {
        disabled = false;
        style = "bg:base16 fg:base01";
        symbols = {
          Windows = "";
          Ubuntu = "󰕈";
          SUSE = "";
          Raspbian = "󰐿";
          Mint = "󰣭";
          Macos = "󰀵";
          Manjaro = "";
          Linux = "󰌽";
          Gentoo = "󰣨";
          Fedora = "󰣛";
          Alpine = "";
          Amazon = "";
          Android = "";
          Arch = "󰣇";
          Artix = "󰣇";
          CentOS = "";
          Debian = "󰣚";
          Redhat = "󱄛";
          RedHatEnterprise = "󱄛";
        };
        format = "[ $symbol ]($style)";
      };

      username = {
        show_always = true;
        style_user = "bg:base16";
        style_root = "bg:base16";
        format = "[ $user]($style)";
      };

      fill = {
        symbol = " ";
      };

      directory = {
        style = "bold fg:base0C";
        format = "[$path]($style)[$read_only]($read_only_style) ";
        read_only_style = "base0E";
        read_only = "  ";
        fish_style_pwd_dir_length = 1;
        truncation_length = 3;
        truncation_symbol = "  ";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = "󰉍 ";
          "Music" = "󰝚 ";
          "Pictures" = "󰋪 ";
          "Developer" = "󰲋 ";
          "dev" = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:base02 fg:base04";
        format = "[[ $symbol $branch ](bg:base02 fg:base04)]($style)";
      };

      git_status = {
        style = "bg:base02 fg:base04";
        format = "[[($all_status$ahead_behind )](bg:base02 fg:base04)]($style)";
      };

      git_state = {
        style = "bg:base02 fg:base04";
      };

      git_commit = {
        tag_symbol = "";
        style = "bg:base02 fg:base04";
        only_detached = false;
        format = "[[$hash$tag ](bg:base02 fg:base04)]($style)";
      };

      nodejs = {
        symbol = " ";
        style = "fg:base0C";
        format = "[[ $symbol( $version) ](fg:base0C)]($style)";
      };

      c = {
        symbol = "󰙱 ";
        style = "fg:base0C";
        format = "[[ $symbol( $version) ](fg:base0C)]($style)";
      };

      rust = {
        symbol = " ";
        style = "fg:base0C";
        format = "[[ $symbol( $version) ](fg:base0C)]($style)";
      };

      golang = {
        symbol = "󰟓 ";
        style = "fg:base0C";
        format = "[[ $symbol( $version) ](fg:base0C)]($style)";
      };

      php = {
        symbol = " ";
        style = "fg:base0C";
        format = "[[ $symbol( $version) ](fg:base0C)]($style)";
      };

      java = {
        symbol = " ";
        style = "fg:base0C";
        format = "[[ $symbol( $version) ](fg:base0C)]($style)";
      };

      kotlin = {
        symbol = " ";
        style = "fg:base0C";
        format = "[[ $symbol( $version) ](fg:base0C)]($style)";
      };

      haskell = {
        symbol = " ";
        style = "fg:base0C";
        format = "[[ $symbol( $version) ](fg:base0C)]($style)";
      };

      python = {
        symbol = " ";
        style = "fg:base0C";
        format = "[[ $symbol( $version)(($virtualenv)) ](fg:base0C)]($style)";
      };

      docker_context = {
        symbol = " ";
        style = "bg:cyan";
        format = "[[ $symbol( $context) ](fg:base00 bg:cyan)]($style)";
      };

      conda = {
        symbol = "  ";
        style = "fg:base00 bg:cyan";
        format = "[$symbol$environment ]($style)";
        ignore_base = false;
      };

      aws = {
        disabled = false;
        force_display = false;
        expiration_symbol = "󱋠 ";
        format = "[$symbol($profile )(󱎫 $duration )]($style)";
        symbol = " ";
        style = "base04";
        region_aliases = {
          "us-east-1" = "🇺🇸 east-1";
          "us-east-2" = "🇺🇸 east-2";
          "us-west-1" = "🇺🇸 west-1";
          "us-west-2" = "🇺🇸 west-2";
          "ca-central-1" = "🇨🇦";
          "sa-east-1" = "🇧🇷";
          "eu-west-1" = "🇮🇪";
          "eu-west-2" = "🇬🇧";
          "eu-west-3" = "🇫🇷";
          "eu-central-1" = "🇩🇪";
          "eu-north-1" = "🇸🇪";
          "ap-southeast-1" = "🇸🇬";
          "ap-southeast-2" = "🇦🇺";
          "ap-northeast-1" = "🇯🇵";
          "ap-northeast-2" = "🇰🇷";
          "ap-south-1" = "🇮🇳";
          "me-south-1" = "🇧🇭";
          "af-south-1" = "🇿🇦";
        };
      };

      battery = {
        full_symbol = "󰁹 ";
        charging_symbol = "󰂄 ";
        discharging_symbol = "󰂃 ";
        unknown_symbol = "󰁽 ";
        empty_symbol = "󰁺 ";
        format = "[[ $symbol]($style)$percentage ](bg:base02 fg:base04)";
        display = [
          {
            threshold = 10;
            style = "bold fg:red bg:base02";
          }
          {
            threshold = 40;
            style = "bold fg:orange bg:base02";
          }
          {
            threshold = 70;
            style = "bold fg:yellow bg:base02";
          }
          {
            threshold = 100;
            style = "bold fg:green bg:base02";
          }
        ];
      };

      memory_usage = {
        disabled = false;
        threshold = 1;
        style = "fg:base04 bg:base02";
        format = "[ $symbol $ram_pct]($style)";
        symbol = "󰍛 ";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "fg:base00 bg:base16";
        format = "[  $time ]($style)";
      };

      character = {
        disabled = false;
        success_symbol = "[❯](bold fg:green)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:green)";
        vimcmd_replace_one_symbol = "[❮](bold fg:purple)";
        vimcmd_replace_symbol = "[❮](bold fg:purple)";
        vimcmd_visual_symbol = "[❮](bold fg:yellow)";
      };

      cmd_duration = {
        show_milliseconds = true;
        format = " 󱦟 $duration ";
        style = "bg:base01";
        disabled = false;
        show_notifications = false;
        min_time_to_notify = 45000;
      };

      # palette = "base16";
      # palettes.base16 = {
      #   base00 = "#2e3440";
      #   base01 = "#3b4252";
      #   base02 = "#434c5e";
      #   base03 = "#4c566a";
      #   base04 = "#d8dee9";
      #   base05 = "#e5e9f0";
      #   base06 = "#eceff4";
      #   base07 = "#8fbcbb";
      #   base08 = "#bf616a";
      #   base09 = "#d08770";
      #   base0A = "#ebcb8b";
      #   base0B = "#a3be8c";
      #   base0C = "#88c0d0";
      #   base0D = "#81a1c1";
      #   base0E = "#b48ead";
      #   base0F = "#5e81ac";
      #   base10 = "#2e3440";
      #   base11 = "#2e3440";
      #   base12 = "#bf616a";
      #   base13 = "#ebcb8b";
      #   base14 = "#a3be8c";
      #   base15 = "#88c0d0";
      #   base16 = "#81a1c1";
      #   base17 = "#b48ead";
      #   black = "#2e3440";
      #   blue = "#81a1c1";
      #   bright-black = "#4c566a";
      #   bright-blue = "#81a1c1";
      #   bright-cyan = "#88c0d0";
      #   bright-green = "#a3be8c";
      #   bright-magenta = "#b48ead";
      #   bright-purple = "#b48ead";
      #   bright-red = "#bf616a";
      #   bright-white = "#8fbcbb";
      #   bright-yellow = "#ebcb8b";
      #   brown = "#5e81ac";
      #   cyan = "#88c0d0";
      #   green = "#a3be8c";
      #   magenta = "#b48ead";
      #   orange = "#d08770";
      #   purple = "#b48ead";
      #   red = "#bf616a";
      #   white = "#e5e9f0";
      #   yellow = "#ebcb8b";
      # };
    };
  };
}
