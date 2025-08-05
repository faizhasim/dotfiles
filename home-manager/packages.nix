{ pkgs }:

with pkgs;
[
  # A
  aerospace
  aspell # Spell checker
  aspellDicts.en # English dictionary for aspell

  # B
  bat # Cat clone with syntax highlighting
  btop # System monitor and process viewer

  # C
  coreutils # Basic file/text/shell utilities
  curl

  # D
  diffutils
  direnv # Environment variable management per directory
  difftastic # Structural diff tool
  # discord
  dockutil # Manage icons in the dock
  du-dust # Disk usage analyzer

  # F
  fd # Fast find alternative
  ffmpeg # Multimedia framework
  fswatch # File change monitor
  fzf # Fuzzy finder

  # G
  gcc # GNU Compiler Collection
  git
  gh # GitHub CLI
  glow # Markdown renderer for terminal
  gnupg # GNU Privacy Guard
  gopls # Go language server

  # H
  htop # Interactive process viewer
  # hunspell # Spell checker

  # I
  iftop # Network bandwidth monitor
  iina
  # imagemagick # Image manipulation toolkit

  # J
  jankyborders
  jetbrains-toolbox # JetBrains IDEs manager is unfree
  jpegoptim # JPEG optimizer
  jq # JSON processor

  # K
  keycastr
  killall # Kill processes by name

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
  ngrok # Secure tunneling service, unfree

  # O
  # obs-studio # Stream / recording software
  openssh # SSH client and server
  openai-whisper

  # P
  pandoc # Document converter

  # S
  slack # unfree, use brew cask instead
  sniffnet # monitor network traffic

  # T
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

  # V
  vscode # Visual Studio Code, unfree

  # W
  wezterm # Terminal emulator
  wget

  # Z
  zip # ZIP archive creator
  zsh
  # zsh-powerlevel10k # Zsh theme
]