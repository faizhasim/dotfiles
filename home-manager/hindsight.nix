{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.home) homeDirectory;

  # Wrapper script that sources the API key from a file and starts
  # hindsight-local-mcp. launchd has no shell env — no mise, no uv on PATH.
  # This wrapper uses pkgs.uv (from nix store) to ensure uvx is found.
  hsServer = pkgs.writeShellApplication {
    name = "hindsight-server";
    runtimeInputs = with pkgs; [
      uv
      coreutils
    ];
    text = ''
      set -euo pipefail

      KEY_FILE="$HOME/.hindsight/api-key"

      if [[ ! -f "$KEY_FILE" ]]; then
        echo "hindsight: no api key at $KEY_FILE — run 'setup-post-nix.sh omp' first" >&2
        exit 1
      fi

      export HINDSIGHT_API_LLM_PROVIDER=opencode-go
      export HINDSIGHT_API_LLM_API_KEY
      HINDSIGHT_API_LLM_API_KEY=$(cat "$KEY_FILE")

      exec uvx --quiet --from hindsight-api hindsight-local-mcp
    '';
  };
in
{
  # ── LaunchAgent: hindsight memory server ──
  # Runs hindsight-local-mcp on port 8888 on login.
  # launchd manages the lifecycle; use KeepAlive so it stays up.
  home.file."Library/LaunchAgents/io.vectorize.hindsight.plist" = {
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
        "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>io.vectorize.hindsight</string>
        <key>ProgramArguments</key>
        <array>
          <string>${hsServer}/bin/hindsight-server</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ThrottleInterval</key>
        <integer>10</integer>
        <key>StandardOutPath</key>
        <string>${homeDirectory}/.hindsight/launchd.log</string>
        <key>StandardErrorPath</key>
        <string>${homeDirectory}/.hindsight/launchd.log</string>
        <key>WorkingDirectory</key>
        <string>${homeDirectory}</string>
      </dict>
      </plist>
    '';
    force = true;
  };

  # Activation block: reload plist on rebuild so launchd picks up the
  # new nix-store path (which changes on every flake rebuild).
  home.activation.startHindsight = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PLIST="$HOME/Library/LaunchAgents/io.vectorize.hindsight.plist"
    if [[ -f "$PLIST" ]]; then
      launchctl bootout "gui/$(id -u)/io.vectorize.hindsight" 2>/dev/null || true
      launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null || true
      launchctl kickstart -k "gui/$(id -u)/io.vectorize.hindsight" 2>/dev/null || true
    fi
  '';
}
