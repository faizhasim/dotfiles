# DNS Management with dnsmasq

This dotfiles configuration includes per-repository DNS management using `dnsmasq` integrated with `direnv`.

## Overview

Instead of manually editing `/etc/hosts` or managing DNS entries globally, you can define DNS entries per-repository in your `.envrc` files. This provides:

- **Per-repo DNS configuration**: Each project defines its own development domains
- **Persistent entries**: DNS entries remain active until manually removed
- **Wildcard support**: Use patterns like `*.dev.local` for flexible domain matching
- **Team shareable**: Commit `.envrc` to version control for team consistency
- **No sudo for daily use**: After initial setup, no elevated permissions needed

## Architecture

- **dnsmasq**: Runs as a user-level launchd service on macOS
- **Port 53535**: Avoids conflict with macOS system DNS (port 53) and mDNSResponder (port 5353)
- **Modular config**: `~/.config/dnsmasq.d/` contains per-directory config files
- **macOS resolvers**: `/etc/resolver/` files route specific domains to dnsmasq

## Initial Setup

The setup happens automatically during `darwin-rebuild switch`. The process:

1. Installs `dnsmasq` package
2. Creates configuration files in `~/.config/dnsmasq.conf`
3. Creates modular config directory at `~/.config/dnsmasq.d/`
4. Sets up launchd service to run dnsmasq on login

After rebuild, verify dnsmasq is running:

```bash
# Check service status
launchctl list | grep dnsmasq

# Should show something like:
# 12345  0  org.nixos.dnsmasq
```

**Note**: The `/etc/resolver/` directory and individual resolver files will be created automatically the first time you use `use dns` in any `.envrc` file. This may prompt for sudo password.

## Usage

### Basic DNS Entry

In your project's `.envrc` file:

```bash
# Add development domain pointing to localhost (127.0.0.1)
use dns dev.seek.com.au
```

This creates:
- A dnsmasq config entry: `address=/dev.seek.com.au/127.0.0.1`
- A macOS resolver: `/etc/resolver/dev.seek.com.au`

All domains automatically resolve to `127.0.0.1` (localhost).

### Multiple Domains

```bash
use dns dev.seek.com.au
use dns dev.seek.co.nz
use dns dev.hk.jobsdb.com
use dns dev.th.jobsdb.com
use dns dev.my.jobstreet.com
```

### Wildcard Domains

For pattern-based matching:

```bash
# All subdomains of *.dev.local resolve to 127.0.0.1
use dns "*.dev.local"

# All subdomains of *.test.internal
use dns "*.test.internal"
```

Note: More specific domains take precedence over wildcards.

### Complete Example

```bash
# .envrc for a full-stack project
#!/usr/bin/env bash

# Runtime versions
use mise

# Frontend domains
use dns app.dev.local
use dns "*.app.dev.local"

# Backend services
use dns api.dev.local
use dns graphql.dev.local

# Infrastructure services
use dns postgres.dev.local
use dns redis.dev.local
use dns rabbitmq.dev.local

# External service mocks
use dns mock-payment-gateway.local
use dns mock-auth-service.local

# Project-specific environment variables
export NODE_ENV=development
export API_BASE_URL=https://api.dev.local
export DATABASE_URL=postgresql://localhost:5432/myapp
```

All DNS entries automatically resolve to `127.0.0.1`.

## How It Works

### Directory Entry

When you `cd` into a directory with `.envrc` containing `use dns` statements:

```bash
$ cd ~/projects/my-project
direnv: loading ~/projects/my-project/.envrc
DNS: dev.seek.com.au -> 127.0.0.1
DNS: api.local -> 127.0.0.1
```

direnv executes the `.envrc` file, which:
1. Generates a unique session ID based on the directory path
2. Creates a config file at `~/.config/dnsmasq.d/direnv-<hash>.conf`
3. Adds DNS entries to the config file
4. Creates macOS resolver files in `/etc/resolver/`
5. Signals dnsmasq to reload configuration

### Persistence

DNS entries are **persistent** - they remain active even after you leave the directory. This design choice ensures:

- Predictable behavior (entries don't disappear unexpectedly)
- No cleanup complexity
- Entries are available system-wide once configured
- Safe to have multiple projects with different domains

### Testing DNS Resolution

```bash
# Test with ping
ping dev.seek.com.au
# PING dev.seek.com.au (127.0.0.1): 56 data bytes

# Test with nslookup
nslookup dev.seek.com.au
# Server:    127.0.0.1
# Address:   127.0.0.1#5353
# Name:      dev.seek.com.au
# Address:   127.0.0.1

# Test with dig
dig dev.seek.com.au
# Should show 127.0.0.1 in the answer section

# Check macOS resolver configuration
scutil --dns | grep -A 3 "resolver #"
```

## Manual Management

### View Active Configuration

```bash
# List all dnsmasq config files
ls -la ~/.config/dnsmasq.d/

# View a specific project's config
cat ~/.config/dnsmasq.d/direnv-*.conf

# List all macOS resolvers
ls -la /etc/resolver/
```

### Manual Cleanup

If you want to remove DNS entries:

```bash
# Remove specific directory's DNS config
rm ~/.config/dnsmasq.d/direnv-<hash>.conf

# Remove all direnv-managed DNS configs
rm ~/.config/dnsmasq.d/direnv-*.conf

# Remove specific resolver (requires sudo)
sudo rm /etc/resolver/<domain>

# Reload dnsmasq to apply changes
pkill -HUP dnsmasq
```

### Service Management

```bash
# Check if dnsmasq is running
launchctl list | grep dnsmasq

# View logs
tail -f ~/.local/var/log/dnsmasq.log

# Restart service
launchctl stop org.nixos.dnsmasq
launchctl start org.nixos.dnsmasq

# Or reload configuration without restart
pkill -HUP dnsmasq
```

## Troubleshooting

### DNS Not Resolving

1. **Check dnsmasq is running**:
   ```bash
   launchctl list | grep dnsmasq
   ```
   
2. **Check dnsmasq logs**:
   ```bash
   tail -f ~/.local/var/log/dnsmasq.log
   ```

3. **Verify configuration file exists**:
   ```bash
   ls -la ~/.config/dnsmasq.d/direnv-*.conf
   ```

4. **Check resolver file exists**:
   ```bash
   ls -la /etc/resolver/<domain>
   cat /etc/resolver/<domain>
   ```

5. **Flush DNS cache**:
   ```bash
   sudo dscacheutil -flushcache
   sudo killall -HUP mDNSResponder
   ```

### Port Conflict

If dnsmasq fails to start due to port 5353 being in use:

```bash
# Check what's using port 5353
lsof -i :5353

# If needed, change port in ~/.config/dnsmasq.conf
# and update all /etc/resolver/* files accordingly
```

### Permission Issues

If you see permission errors when creating resolver files:

```bash
# The first time you use 'use dns', you'll be prompted for sudo to create:
# 1. /etc/resolver/ directory
# 2. Individual resolver files

# This is a one-time setup per domain
# After that, the resolver files persist and no sudo is needed
```

If the sudo prompt fails or you want to set it up manually:

```bash
# Create the directory once
sudo mkdir -p /etc/resolver

# Optionally, give yourself ownership to avoid future sudo prompts
sudo chown -R $USER /etc/resolver
```

### Idempotency Check

Running `direnv allow` multiple times is safe and won't create duplicate entries:

```bash
$ direnv allow
DNS: dev.seek.com.au -> 127.0.0.1 (already configured)
```

## Advanced Usage

### Conditional DNS

Only enable DNS for specific conditions:

```bash
# .envrc
if command -v docker >/dev/null 2>&1; then
  use dns postgres.local
  use dns redis.local
fi
```

### Integration with Docker Compose

```yaml
# docker-compose.yml
services:
  api:
    container_name: api.dev.local
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres.dev.local:5432/myapp
```

```bash
# .envrc
use dns api.dev.local
use dns postgres.dev.local
```

## Best Practices

1. **Commit `.envrc` to version control**: Share DNS configuration with your team
2. **Use descriptive domain names**: `api.projectname.local` instead of just `api.local`
3. **Avoid wildcards unless necessary**: Specific domains are more predictable
4. **Test DNS resolution**: After adding entries, verify with `ping` or `nslookup`
5. **Keep domains unique**: Avoid conflicts between different projects

## Security Considerations

- DNS entries are **not encrypted** (this is local development DNS)
- Entries are **system-wide** after creation (any process can resolve them)
- `/etc/resolver/` files may require **sudo** for creation (one-time)
- **Don't use** for production DNS management
- **Don't expose** sensitive services on public IPs via DNS entries

## Uninstalling

To completely remove dnsmasq:

```bash
# Stop service
launchctl stop org.nixos.dnsmasq

# Remove from nix configuration
# (Remove dnsmasq from home-manager/packages/common.nix)
# (Remove ./dnsmasq.nix import from home-manager/default.nix)

# Rebuild
darwin-rebuild switch --flake .#<hostname>

# Manual cleanup
rm -rf ~/.config/dnsmasq.conf ~/.config/dnsmasq.d/
sudo rm -rf /etc/resolver/*
rm -f ~/.local/var/log/dnsmasq.log
```

## References

- [dnsmasq official documentation](http://www.thekelleys.org.uk/dnsmasq/doc.html)
- [macOS resolver man page](https://www.manpagez.com/man/5/resolver/)
- [direnv documentation](https://direnv.net/)
