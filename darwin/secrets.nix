# agenix secrets configuration for nix-darwin
# Configures secret decryption and deployment
{
  config,
  pkgs,
  lib,
  inputs,
  hostname,
  ...
}:
let
  # Generator script using gomplate for clean templating
  generateGhDashConfig = pkgs.writeShellScript "generate-gh-dash-config" ''
    set -euo pipefail
    export PATH="${
      pkgs.lib.makeBinPath [
        pkgs.gomplate
        pkgs.yq-go
        pkgs.jq
        pkgs.coreutils
      ]
    }:$PATH"
    ${builtins.readFile ../scripts/generate-gh-dash-config.sh}
  '';

  # Gomplate template copied to Nix store
  gomplateTemplate = pkgs.writeText "gh-dash-config.gomplate.yml" (
    builtins.readFile ../home-manager/gh-dash/config.gomplate.yml
  );
in
{
  age = {
    # Specify which SSH key(s) to use for decryption
    # The key is stored in 1Password (document: "agenix-decryption-key")
    # and extracted at activation time by the preActivation script below
    identityPaths = [ "/Users/${config.system.primaryUser}/.ssh/agenix-key" ];

    # Define secrets and where they should be deployed after decryption
    secrets = {
      worktrunk-repos = {
        # Source: encrypted file in repository
        file = ../secrets/worktrunk-repos.toml.age;
        # Destination: worktrunk repo catalog (used by multiple tools like gh-dash)
        path = "/Users/${config.system.primaryUser}/.config/worktrunk/repos.toml";
        # Set ownership to the primary user
        owner = config.system.primaryUser;
        # Set permissions (read/write for owner only)
        mode = "0600";
      };
    };
  };

  # Extract agenix decryption key from 1Password before secrets are decrypted
  # NOTE: This runs as root, so it can only extract the key if:
  # 1. The key already exists (extracted by user beforehand), OR
  # 2. 1Password service account token is set via OP_SERVICE_ACCOUNT_TOKEN
  system.activationScripts.preActivation.text = lib.mkBefore ''
    AGENIX_KEY_PATH="/Users/${config.system.primaryUser}/.ssh/agenix-key"

    if [ ! -f "$AGENIX_KEY_PATH" ]; then
      echo >&2 "⚠️  Agenix key not found at $AGENIX_KEY_PATH"
      echo >&2 "Attempting to extract from 1Password..."
      
      if ${pkgs.lib.getExe pkgs._1password-cli} document get "agenix-decryption-key" --vault Private > "$AGENIX_KEY_PATH" 2>/dev/null; then
        chmod 600 "$AGENIX_KEY_PATH"
        echo >&2 "✓ Successfully extracted agenix key from 1Password"
      else
        echo >&2 ""
        echo >&2 "❌ Failed to extract agenix key from 1Password."
        echo >&2 ""
        echo >&2 "This activation script runs as root and doesn't have access to your 1Password CLI session."
        echo >&2 ""
        echo >&2 "Please run this command in your user session BEFORE darwin-rebuild:"
        echo >&2 "  op document get 'agenix-decryption-key' --vault Private > ~/.ssh/agenix-key && chmod 600 ~/.ssh/agenix-key"
        echo >&2 ""
        exit 1
      fi
    else
      echo >&2 "✓ Agenix key already exists at $AGENIX_KEY_PATH"
    fi
  '';

  # Run script to generate gh-dash config after secrets are decrypted
  # Pass template path and user's home directory (activation runs as root)
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo >&2 "Generating gh-dash config from gomplate template + decrypted repos.toml..."
    ${generateGhDashConfig} "${gomplateTemplate}" "/Users/${config.system.primaryUser}"
  '';
}
