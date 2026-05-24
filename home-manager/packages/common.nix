{ pkgs }:

with pkgs;
[
  # ──────────────────────────────────────────────
  # 📟 Terminal & Shell
  # ──────────────────────────────────────────────
  zsh
  wezterm # Terminal emulator
  zellij # terminal multiplexer
  tmux # Terminal multiplexer
  direnv # Environment variable management per directory
  stow
  ncurses # Terminal control library with terminfo database

  # ──────────────────────────────────────────────
  # ⚙️ Core CLI Utilities
  # ──────────────────────────────────────────────
  coreutils-full # multiple tools
  diffutils
  findutils
  gnugrep
  gnumake
  gnused
  gnutar
  gawk
  gzip
  killall # Kill processes by name
  tree # Directory tree viewer
  curl
  wget
  openssh # SSH client and server
  unrar # RAR archive extractor
  unzip # ZIP archive extractor
  zip # ZIP archive creator
  the-unarchiver

  # ──────────────────────────────────────────────
  # 🔍 Search & Text Processing
  # ──────────────────────────────────────────────
  ripgrep # fast searching
  fd # Fast find alternative
  bat # Cat clone with syntax highlighting
  fzf # Fuzzy finder
  glow # Markdown renderer for terminal
  gum # Interactive prompts for shell scripts
  grc # colored log output
  tealdeer # community driven man pages
  difftastic # Structural diff tool
  vale
  sqlfluff # sql linter and auto-formatter
  fblog # json log viewer

  # ──────────────────────────────────────────────
  # ✏️ Editors
  # ──────────────────────────────────────────────
  neovim
  vscode # Visual Studio Code, unfree

  # ──────────────────────────────────────────────
  # 🦀 Development — Languages & Runtimes
  # ──────────────────────────────────────────────
  gcc # GNU Compiler Collection
  lua
  rustup # rust
  mise
  corepack # node wrappers
  (python3.withPackages (
    ps: with ps; [
      pdfplumber
      pypdf
      reportlab
      pytesseract
      pdf2image
      pandas
    ]
  ))
  # uv # Python package installer

  # ──────────────────────────────────────────────
  # 🔧 Development — LSPs, Linters & Formatters
  # ──────────────────────────────────────────────
  nil # nix language server
  nixd # nix language server
  nixfmt
  statix
  prettier
  ast-grep # code searching and refactoring tool
  tree-sitter # incremental parsing system (used by neovim)
  gopls # Go language server
  golangci-lint
  copilot-language-server # use by sidekick.nvim
  rubyPackages.htmlbeautifier
  proto # used by moonrepo
  # comma is provided by nix-index-database (programs.nix-index-database.comma.enable = true)

  # ──────────────────────────────────────────────
  # 📦 Git & Version Control
  # ──────────────────────────────────────────────
  git
  git-lfs
  gh # GitHub CLI
  github-copilot-cli # required by nvim sidekick
  delta # git diff viewer
  goreleaser # Go release automation

  # ──────────────────────────────────────────────
  # ☸️ Kubernetes & Containers
  # ──────────────────────────────────────────────
  kubectl
  kubie # fzf kubeconfig browser
  krew # kubectl plugins
  kubernetes-helm # deploy applications
  k3d
  tilt # k8s dev tool
  dive # analyse docker images
  # kind # k8s in docker

  # ──────────────────────────────────────────────
  # ☁️ Cloud & IaC
  # ──────────────────────────────────────────────
  awscli2
  terraform # Infrastructure as code tool
  terraform-docs
  tflint # Terraform linter
  # terraform-ls # Terraform language server
  saml2aws # SAML to AWS CLI authentication tool
  rclone # sync files
  ngrok # Secure tunneling service, unfree
  age # Encryption tool for secrets (used by agenix)
  ssh-to-age # Convert SSH keys to age format (used by agenix)

  # ──────────────────────────────────────────────
  # 🗃️ Data & Databases
  # ──────────────────────────────────────────────
  jq # JSON processor
  yq-go
  gomplate # Template engine for generating text files
  graph-easy # draw graphs in the terminal
  postgresql # Database server
  bats # Bash automated testing system
  k6 # load testing tool

  # ──────────────────────────────────────────────
  # 📡 Networking & Security
  # ──────────────────────────────────────────────
  nmap # net tools
  bind # nettools
  inetutils # net tools like ping, traceroute, etc.
  iftop # Network bandwidth monitor
  gping # ping with a graph
  dnsmasq # DNS forwarder and DHCP server
  gnupg # GNU Privacy Guard
  sshfs # mount folders via ssh
  httpie # awesome alternative to curl
  # libfido2 # FIDO2 library

  # ──────────────────────────────────────────────
  # 📄 PDF & Document Processing
  # ──────────────────────────────────────────────
  pandoc # Document converter
  tectonic # pdf latex
  pdftk # PDF toolkit for merging, splitting, rotating
  qpdf # PDF manipulation CLI
  poppler-utils # provides pdftotext, pdfimages
  ocrmypdf # OCR engine wrapper producing searchable PDF/A output
  tesseract # OCR engine
  ghostscriptX

  # ──────────────────────────────────────────────
  # 🎨 Media & Graphics
  # ──────────────────────────────────────────────
  ffmpeg # video editing and cutting
  iina
  yt-dlp
  openai-whisper
  mermaid-cli # generate diagrams and flowcharts from text
  imagemagick # Image manipulation toolkit
  jpegoptim # JPEG optimizer
  pngpaste # paste PNG image from clipboard
  drawio # Draw.io diagram editor
  slides
  presenterm # presentation tool
  slack # unfree, use brew cask instead
  # obs-studio # Stream / recording software

  # ──────────────────────────────────────────────
  # 💻 macOS Desktop
  # ──────────────────────────────────────────────
  aerospace
  betterdisplay
  dockutil # Manage icons in the dock
  loopwm # Tiling window manager, unfree
  raycast
  keycastr
  mas
  sniffnet # monitor network traffic
  utm # Virtual machines

  # ──────────────────────────────────────────────
  # 📊 System Monitoring
  # ──────────────────────────────────────────────
  htop # Interactive process viewer
  btop # System monitor and process viewer
  neohtop # nice htop GUI alternative
  duf # disk usage
  dust # disk usage analyzer
  fastfetch # System information tool
  fswatch # File change monitor
  lnav # Log file navigator
  termdown # terminal countdown

  # ──────────────────────────────────────────────
  # 🔤 Spelling & Writing
  # ──────────────────────────────────────────────
  aspell # Spell checker
  aspellDicts.en # English dictionary for aspell
  # hunspell # Spell checker
]
