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

  # Verify agenix decryption key exists before proceeding
  # The key must be extracted manually BEFORE running darwin-rebuild:
  #   op document get 'agenix-decryption-key' --vault Private > ~/.ssh/agenix-key && chmod 600 ~/.ssh/agenix-key
  #
  # NOTE: We cannot extract from 1Password during activation because:
  # - Activation runs as root, which doesn't have access to user's 1Password CLI session
  # - Interactive prompts would block the build
  # - Only works if OP_SERVICE_ACCOUNT_TOKEN is set (for CI/automation)
  system.activationScripts.preActivation.text = lib.mkBefore ''
    AGENIX_KEY_PATH="/Users/${config.system.primaryUser}/.ssh/agenix-key"

    # Check if key exists AND has content
    if [ -s "$AGENIX_KEY_PATH" ]; then
      echo >&2 "✓ Agenix key exists at $AGENIX_KEY_PATH"
      chmod 600 "$AGENIX_KEY_PATH" 2>/dev/null || true
    else
      # If OP_SERVICE_ACCOUNT_TOKEN is set, try non-interactive extraction
      if [ -n "''${OP_SERVICE_ACCOUNT_TOKEN:-}" ]; then
        echo >&2 "Attempting non-interactive 1Password extraction (service account)..."
        if ${pkgs.lib.getExe pkgs._1password-cli} document get "agenix-decryption-key" --vault Private > "$AGENIX_KEY_PATH" 2>/dev/null && [ -s "$AGENIX_KEY_PATH" ]; then
          chmod 600 "$AGENIX_KEY_PATH"
          echo >&2 "✓ Successfully extracted agenix key via service account"
        else
          rm -f "$AGENIX_KEY_PATH"
          # Fall through to error message
        fi
      fi

      # Still no key? Fail with clear instructions
      if [ ! -s "$AGENIX_KEY_PATH" ]; then
        # Clean up any empty/broken file
        [ -f "$AGENIX_KEY_PATH" ] && rm -f "$AGENIX_KEY_PATH"

        echo >&2 ""
        echo >&2 "❌ Agenix decryption key not found at $AGENIX_KEY_PATH"
        echo >&2 ""
        echo >&2 "This must be extracted BEFORE running darwin-rebuild."
        echo >&2 ""
        echo >&2 "Run this command first (without sudo):"
        echo >&2 "  op document get 'agenix-decryption-key' --vault Private > ~/.ssh/agenix-key && chmod 600 ~/.ssh/agenix-key"
        echo >&2 ""
        echo >&2 "Then retry: sudo darwin-rebuild switch --flake .#${hostname}"
        echo >&2 ""
        exit 1
      fi
    fi
  '';

  # Run script to generate gh-dash config after secrets are decrypted
  # Pass template path and user's home directory (activation runs as root)
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo >&2 "Generating gh-dash config from gomplate template + decrypted repos.toml..."
    ${generateGhDashConfig} "${gomplateTemplate}" "/Users/${config.system.primaryUser}"
  '';
}
