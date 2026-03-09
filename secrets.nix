# Secrets access control for agenix
# Defines WHO can decrypt WHAT secrets
#
# NOTE: This file is evaluated standalone by the agenix CLI (not as a NixOS/darwin module),
# so it cannot import from flake.nix. The key here must stay in sync with
# primarySshKey in flake.nix.
#
# The private key is stored in 1Password (document: "agenix-decryption-key")
# and extracted at system activation time.
let
  # SSH public key (stored in 1Password, extracted to ~/.ssh/agenix-key at runtime)
  # IMPORTANT: Use SSH public key format (not age format) for agenix!
  # When agenix re-encrypts, it must use SSH recipients so the SSH private key can decrypt.
  faizhasim = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDmhrC+z9U+SYnvXhXRBWK47H34TMMr8cBdVpXuVHAAO";

  # All authorized keys
  allKeys = [ faizhasim ];
in
{
  # Worktrunk repository catalog (used by gh-dash and other tools)
  "secrets/worktrunk-repos.toml.age".publicKeys = allKeys;
}
