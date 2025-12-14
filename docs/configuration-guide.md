# Configuration Guide

This guide shows you how to customize and extend the dotfiles system for your own needs.

## Adding Packages

### Adding Nix Packages

Nix packages are defined in `home-manager/packages/`.

#### Add to All Machines

Edit `home-manager/packages/common.nix`:

```nix
{pkgs, ...}: {
  home.packages = with pkgs; [
    # ... existing packages ...
    
    # Add your package here
    ripgrep
    jq
  ];
}
```

#### Add to Specific Machine

Edit `home-manager/packages/{hostname}.nix` (e.g., `M3419.nix`):

```nix
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Machine-specific packages
    colima
    docker
  ];
}
```

> [!TIP]
> Search for available packages at [search.nixos.org](https://search.nixos.org/packages)

### Adding Homebrew Packages

Homebrew packages are defined in `darwin/homebrew/`.

#### Add GUI Application (Cask)

Edit `darwin/homebrew/common.nix`:

```nix
{
  casks = [
    # ... existing casks ...
    "visual-studio-code"
    "spotify"
  ];
}
```

#### Add CLI Tool (Brew)

```nix
{
  brews = [
    # ... existing brews ...
    "terraform"
    "awscli"
  ];
}
```

#### Add from Custom Tap

```nix
{
  taps = [
    "homebrew/cask-fonts"
  ];
  
  casks = [
    "font-fira-code-nerd-font"
  ];
}
```

> [!NOTE]
> Search for casks at [formulae.brew.sh](https://formulae.brew.sh/cask/)

### Adding App Store Apps

Edit `darwin/homebrew/common.nix`:

```nix
{
  masApps = {
    "Amphetamine" = 937984704;
    "Keynote" = 409183694;
  };
}
```

To find the App Store ID:

```bash
mas search "App Name"
```

## Customizing System Preferences

macOS system preferences are in `darwin/os/`.

### Dock Settings

Edit `darwin/os/dock.nix`:

```nix
{
  system.defaults.dock = {
    tilesize = 48;           # Icon size
    autohide = true;         # Auto-hide dock
    orientation = "bottom";  # Dock position
    show-recents = false;    # Hide recent apps
  };
}
```

### Finder Settings

Edit `darwin/os/finder.nix`:

```nix
{
  system.defaults.finder = {
    AppleShowAllExtensions = true;  # Show file extensions
    ShowPathbar = true;             # Show path bar
    FXPreferredViewStyle = "Nlsv";  # List view by default
  };
}
```

### Keyboard Settings

Edit `darwin/os/keyboard.nix`:

```nix
{
  system.defaults.NSGlobalDomain = {
    KeyRepeat = 2;                    # Faster key repeat
    InitialKeyRepeat = 15;            # Shorter delay
    ApplePressAndHoldEnabled = false; # Disable accents menu
  };
}
```

> [!TIP]
> See [darwin options](https://daiderd.com/nix-darwin/manual/index.html#sec-options) for all available settings.

### Settings Not in nix-darwin

Some settings require manual `defaults write` commands. Add them to activation scripts in `darwin/default.nix`:

```nix
{
  system.activationScripts.postActivation.text = ''
    # Set screenshot location
    defaults write com.apple.screencapture location ~/Pictures/Screenshots
    
    # Disable screenshot thumbnail
    defaults write com.apple.screencapture show-thumbnail -bool false
  '';
}
```

## Customizing Shell Configuration

Shell setup is in `home-manager/zsh.nix`.

### Adding Aliases

```nix
{
  programs.zsh.shellAliases = {
    # ... existing aliases ...
    
    # Add your aliases
    gs = "git status";
    gp = "git push";
    k = "kubectl";
  };
}
```

### Adding Functions

```nix
{
  programs.zsh.initExtra = ''
    # Add custom function
    mkcd() {
      mkdir -p "$1" && cd "$1"
    }
    
    # Kubernetes context switcher
    kctx() {
      kubectl config use-context "$1"
    }
  '';
}
```

### Adding Plugins

Using Oh-My-Zsh plugins:

```nix
{
  programs.zsh.oh-my-zsh = {
    plugins = [
      # ... existing plugins ...
      "terraform"
      "kubectl"
    ];
  };
}
```

Custom plugins:

```nix
{
  programs.zsh.plugins = [
    {
      name = "zsh-autosuggestions";
      src = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-autosuggestions";
        rev = "v0.7.0";
        sha256 = "...";
      };
    }
  ];
}
```

## Customizing Git Configuration

Git setup is in `home-manager/git.nix`.

### Adding Git Aliases

```nix
{
  programs.git.aliases = {
    # ... existing aliases ...
    
    # Add your aliases
    co = "checkout";
    br = "branch";
    st = "status";
    last = "log -1 HEAD";
  };
}
```

### Changing Git Settings

```nix
{
  programs.git = {
    userName = "Your Name";
    userEmail = "your.email@example.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
```

## Adding a New Machine

To configure a new machine:

### 1. Create Machine-Specific Files

```bash
# Homebrew packages
touch darwin/homebrew/newmachine.nix

# Nix packages
touch home-manager/packages/newmachine.nix
```

### 2. Define Package Lists

`darwin/homebrew/newmachine.nix`:
```nix
{...}: {
  casks = [
    # Machine-specific casks
  ];
  
  brews = [
    # Machine-specific brews
  ];
}
```

`home-manager/packages/newmachine.nix`:
```nix
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Machine-specific packages
  ];
}
```

### 3. Update flake.nix

Add machine to `darwinConfigurations`:

```nix
{
  darwinConfigurations = {
    # ... existing machines ...
    
    newmachine = createDarwin "newmachine" "yourusername" "aarch64-darwin";
  };
}
```

### 4. Build Configuration

```bash
darwin-rebuild switch --flake .#newmachine
```

## Customizing Terminal (WezTerm)

WezTerm config is in `home-manager/wezterm/wezterm.lua`.

### Changing Font

```lua
config.font = wezterm.font("JetBrains Mono")
config.font_size = 14.0
```

### Changing Color Scheme

```lua
config.color_scheme = "Nord"
-- Or any other from: https://wezfurlong.org/wezterm/colorschemes/
```

### Custom Keybindings

```lua
config.keys = {
  -- Split pane horizontally
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- Split pane vertically
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
}
```

## Customizing Terminal Multiplexer (Zellij)

Zellij config is in `home-manager/zellij/config.kdl` and `home-manager/zellij.nix`.

### Built-in Features

- **Sessionizer** - Quick project switcher (Ctrl+o + w)
- **Session tree** - Visual session browser (Ctrl+o + e)
- **zjstatus** - Custom status bar with Nord theme integration
- **Session management** - Replicated in Zsh for quick access

### Changing Keybindings

Edit `home-manager/zellij/config.kdl`:

```kdl
keybinds {
    normal {
        bind "Alt h" { MoveFocus "Left"; }
        bind "Alt l" { MoveFocus "Right"; }
        bind "Alt j" { MoveFocus "Down"; }
        bind "Alt k" { MoveFocus "Up"; }
    }
}
```

### Session Management from Shell

Zellij sessions can be managed via Zsh aliases:

```bash
# List sessions
zellij ls

# Attach to session (or create if doesn't exist)
zellij attach my-project -c

# Sessionizer (fuzzy finder for project directories)
# Ctrl+o w in Zellij, or run: zellij-sessionizer
```

> [!TIP]
> The sessionizer plugin scans common development directories and lets you quickly switch between projects.

## Customizing Window Manager (AeroSpace)

AeroSpace config is in `home-manager/aerospace/aerospace.toml`.

### Changing Workspaces

```toml
[mode.main.binding]
# Bind different apps to workspaces
cmd-1 = 'workspace 1'
cmd-2 = 'workspace 2'

# Move windows between workspaces
cmd-shift-1 = 'move-node-to-workspace 1'
cmd-shift-2 = 'move-node-to-workspace 2'
```

### Window Management Keybindings

```toml
[mode.main.binding]
# Window focus
cmd-h = 'focus left'
cmd-j = 'focus down'
cmd-k = 'focus up'
cmd-l = 'focus right'

# Window movement
cmd-shift-h = 'move left'
cmd-shift-j = 'move down'
cmd-shift-k = 'move up'
cmd-shift-l = 'move right'
```

### Auto-tiling Rules

```toml
# Automatically tile specific apps
[[on-window-detected]]
if.app-id = 'com.google.Chrome'
run = 'layout tiling'

[[on-window-detected]]
if.app-id = 'com.apple.finder'
run = 'layout floating'
```

> [!NOTE]
> AeroSpace uses raw TOML configuration (not Nix-generated) because Nix's TOML generation produces incorrect indentation that breaks AeroSpace parsing.

## Customizing Neovim

Neovim is managed separately via LazyVim in the `nvim/` directory.

### Adding Plugins

Edit `nvim/lua/plugins/` and create a new file:

```lua
-- nvim/lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  config = function()
    require("plugin-name").setup({
      -- configuration
    })
  end,
}
```

### Changing Keybindings

Edit `nvim/lua/config/keymaps.lua`:

```lua
local map = vim.keymap.set

-- Add your keybindings
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
```

### Configuring LSPs

Edit `nvim/lua/plugins/lsp.lua`:

```lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Add or configure LSP servers
      gopls = {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
          },
        },
      },
    },
  },
}
```

> [!TIP]
> After making changes, run `:Lazy sync` in Neovim to update plugins.

## Managing Runtime Versions (mise)

mise configuration is in `home-manager/mise.nix`.

### Setting Global Versions

```nix
{
  programs.mise.globalConfig.tools = {
    node = "lts";           # Latest LTS
    python = ["3.11" "3.12"]; # Multiple versions
    go = "1.23.5";
    terraform = "1.5.0";
  };
}
```

### Per-Project Versions

Create `.mise.toml` in project directory:

```toml
[tools]
node = "20.10.0"
python = "3.11"
go = "1.22"
```

With direnv integration (`.envrc`):

```bash
use mise
```

> [!NOTE]
> mise will automatically activate when you `cd` into directories with `.mise.toml` if direnv is enabled.

## Local DNS Development (dnsmasq)

dnsmasq configuration is in `home-manager/dnsmasq.nix` for local development domains.

### Usage with direnv

Add to your project's `.envrc`:

```bash
use dns "dev.seek.com.au"
use dns "*.myapp.local"
```

This will:
1. Configure dnsmasq to resolve the domain to 127.0.0.1
2. Create macOS resolver for the domain (port 53535)
3. Automatically clean up when you leave the directory

### Manual dnsmasq Configuration

Add custom domains in `~/.config/dnsmasq.d/`:

```bash
# ~/.config/dnsmasq.d/custom.conf
address=/myapp.local/127.0.0.1
```

Reload dnsmasq:

```bash
pkill -HUP dnsmasq
```

### Testing DNS Resolution

```bash
dig @127.0.0.1 -p 53535 dev.seek.com.au
# Should return: 127.0.0.1

scutil --dns | grep "domain.*dev.seek.com.au"
# Should show resolver configured
```

> [!TIP]
> See [dnsmasq.md](./dnsmasq.md) for detailed configuration and troubleshooting.

## GitHub Dashboard (gh-dash)

gh-dash is configured in `home-manager/gh-dash.nix` for managing pull requests.

### Custom PR Sections

The configuration includes pre-defined sections:

- **author:@me** - Your open PRs
- **review-requested:@me** - PRs awaiting your review
- **mention:@me** - PRs where you're mentioned
- **Team PRs** - All open PRs for configured repositories

### Custom Keybindings

- `m` - Quick merge (squash + auto-merge)
- `x` - Request changes with interactive comment
- `z` - Open PR in Zellij session
- `g` - Open repository in lazygit

### Repository Paths

Configure repository paths in `gh-dash.nix`:

```nix
repoPaths = {
  "myorg/myrepo" = "~/dev/myorg/myrepo";
  "myorg/*" = "~/dev/myorg/*";  # Wildcard support
};
```

> [!NOTE]
> The configuration uses manual YAML generation to prevent line wrapping issues with long filter strings.

## Docker Management (lazydocker)

lazydocker provides a terminal UI for Docker management.

### Usage

```bash
lazydocker
```

Features:
- View and manage containers, images, volumes, networks
- View container logs in real-time
- Execute commands in running containers
- Nord-themed interface (via Stylix)

Configuration is minimal (enabled in `home-manager/lazydocker.nix`).

## Customizing Fonts

Fonts are defined in `darwin/os/fonts.nix`.

### Adding New Fonts

```nix
{pkgs, ...}: {
  fonts.packages = with pkgs; [
    # ... existing fonts ...
    
    # Add Nerd Fonts
    (nerdfonts.override {fonts = ["JetBrainsMono" "FiraCode"];})
    
    # Add system fonts
    fira-code
    jetbrains-mono
  ];
}
```

### Using Homebrew for Fonts

```nix
# darwin/homebrew/common.nix
{
  taps = ["homebrew/cask-fonts"];
  
  casks = [
    "font-jetbrains-mono-nerd-font"
    "font-fira-code-nerd-font"
  ];
}
```

## Applying Changes

After making any configuration changes:

```bash
# Rebuild the system
darwin-rebuild switch --flake .#M3419

# Or use the short alias (if configured)
darwin-rebuild switch --flake .
```

> [!TIP]
> Add an alias for faster rebuilds:
> ```bash
> alias dr="darwin-rebuild switch --flake ."
> ```

## Testing Changes

### Dry Run

See what would change without applying:

```bash
darwin-rebuild build --flake .#M3419
```

### Check Diff

```bash
nix build .#darwinConfigurations.M3419.system
./result/activate-user
```

### Rollback

If something breaks, rollback to previous generation:

```bash
darwin-rebuild --rollback
```

List available generations:

```bash
darwin-rebuild --list-generations
```

## Advanced Customization

### Creating Custom Modules

Create a new module in `home-manager/`:

```nix
# home-manager/my-tool.nix
{config, pkgs, ...}: {
  home.packages = with pkgs; [my-tool];
  
  home.file.".config/my-tool/config.yaml".text = ''
    setting: value
  '';
}
```

Import it in `home-manager/default.nix`:

```nix
{
  imports = [
    # ... existing imports ...
    ./my-tool.nix
  ];
}
```

### Using Secrets with 1Password

Never commit secrets. Use 1Password CLI:

```bash
# In shell config
export AWS_ACCESS_KEY_ID="op://vault/item/field"

# Load with op run
op run -- aws s3 ls
```

Or use 1Password shell plugins:

```nix
# home-manager/zsh.nix
{
  programs.zsh.plugins = [
    {
      name = "1password-shell-plugins";
      src = pkgs.fetchFromGitHub {
        owner = "1Password";
        repo = "shell-plugins";
        # ...
      };
    }
  ];
}
```

### Overriding Package Versions

Create an overlay in `overlays/`:

```nix
# overlays/my-package.nix
final: prev: {
  my-package = prev.my-package.overrideAttrs (old: {
    version = "1.2.3";
    src = final.fetchFromGitHub {
      owner = "author";
      repo = "my-package";
      rev = "v1.2.3";
      sha256 = "...";
    };
  });
}
```

Reference in `flake.nix`:

```nix
{
  nixpkgs.overlays = [
    (import ./overlays/my-package.nix)
  ];
}
```

## Best Practices

### 1. Version Control Everything

Commit all configuration changes:

```bash
git add .
git commit -m "Add ripgrep and update git aliases"
```

### 2. Test Before Committing

```bash
# Build and test
darwin-rebuild switch --flake .

# If it works, commit
git commit -m "Update configuration"
```

### 3. Document Custom Changes

Add comments to explain non-obvious configurations:

```nix
{
  # Required for AWS SSO authentication with Firefox
  homebrew.casks = ["firefox"];
}
```

### 4. Keep Machine-Specific Config Minimal

Put most config in `common.nix` files. Only use machine-specific files for true differences.

### 5. Regular Updates

```bash
# Update flake inputs monthly
nix flake update

# Test the update
darwin-rebuild switch --flake .

# Commit lockfile
git add flake.lock
git commit -m "Update flake inputs"
```

## Next Steps

- Check [Reference](./reference.md) for gotchas and limitations
- Read [Architecture](./architecture.md) to understand the system better
