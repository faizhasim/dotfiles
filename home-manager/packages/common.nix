{ pkgs }:

with pkgs;
[
  # A
  aerospace
  aspell # Spell checker
  aspellDicts.en # English dictionary for aspell
  awscli2

  # B
  bat # Cat clone with syntax highlighting
  bind # nettools
  btop # System monitor and process viewer

  # C
  corepack # node wrappers
  coreutils-full # multiple tools
  comma # run nix binaries on demand
  curl

  # D
  diffutils
  direnv # Environment variable management per directory
  difftastic # Structural diff tool
  # discord
  dive # analyse docker images
  dockutil # Manage icons in the dock
  du-dust # Disk usage analyzer
  duf # disk usage

  # F
  fastfetch
  fd # Fast find alternative
  fblog # json log viewer
  ffmpeg # video editing and cutting
  findutils
  fswatch # File change monitor
  fzf # Fuzzy finder

  # G
  gnupg
  gnugrep
  gnumake
  gnused
  gnutar
  golangci-lint
  gping # ping with a graph
  gzip
  gawk
  gh # GitHub CLI
  git
  git-lfs
  gitAndTools.delta # pretty diff tool
  glow # Markdown renderer for terminal
  gnupg # GNU Privacy Guard
  gopls # Go language server
  graph-easy # draw graphs in the terminal
  grc # colored log output
  gcc # GNU Compiler Collection

  # H
  htop # Interactive process viewer
  httpie # awesome alternative to curl
  # hunspell # Spell checker

  # I
  iftop # Network bandwidth monitor
  iina
  inetutils # net tools like ping, traceroute, etc.
  # imagemagick # Image manipulation toolkit

  # J
  jankyborders
  jetbrains-toolbox # JetBrains IDEs manager is unfree
  jpegoptim # JPEG optimizer
  jq # JSON processor

  # K
  k6 # load testing tool
  keycastr
  kind # k8s in docker
  killall # Kill processes by name
  krew # kubectl plugins
  kubectl
  kubernetes-helm # deploy applications
  kubie # fzf kubeconfig browser

  # L
  lnav # Log file navigator
  loopwm # Tiling window manager, unfree
  # libfido2 # FIDO2 library

  # M
  mise

  # N
  ncurses # Terminal control library with terminfo database
  neovim
  neofetch # System information tool
  neohtop # nice htop GUI alternative
  nmap # net tools
  ngrok # Secure tunneling service, unfree

  # O
  # obs-studio # Stream / recording software
  openssh # SSH client and server
  openai-whisper

  # P
  pandoc # Document converter
  presenterm # presentation tool
  python3

  # R
  rclone # sync files
  ripgrep # fast search
  rustup # rust

  # S
  slack # unfree, use brew cask instead
  slides
  sniffnet # monitor network traffic
  sshfs # mount folders via ssh
  stow

  # T
  tealdeer # community driven man pages
  termdown # terminal countdown
  terraform # Infrastructure as code tool
  terraform-docs
  # terraform-ls # Terraform language server
  tflint # Terraform linter
  the-unarchiver
  tmux # Terminal multiplexer
  tree # Directory tree viewer

  # U
  utm # Virtual machines
  unrar # RAR archive extractor
  unzip # ZIP archive extractor
  # uv # Python package installer


  # W
  wezterm # Terminal emulator
  wget

  # Y
  yq-go
  yt-dlp

  # Z
  zip # ZIP archive creator
  zsh
  # zsh-powerlevel10k # Zsh theme
]
