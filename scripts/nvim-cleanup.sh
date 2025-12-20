#!/usr/bin/env bash
# Neovim Cleanup Script
# Safely kills orphaned nvim processes and language servers

set -euo pipefail

echo "🧹 Cleaning up Neovim processes..."

# Find nvim processes older than 2 days
echo "Looking for zombie nvim processes..."
ps aux | grep "[n]vim --embed" | awk '{print $2, $9, $10, $11}' | while read -r pid start time rest; do
    echo "  Found nvim process: PID=$pid started=$start runtime=$time"
done

# Kill all embedded nvim instances (these are usually from crashed sessions)
NVIM_PIDS=$(pgrep -f "nvim --embed" || true)
if [ -n "$NVIM_PIDS" ]; then
    echo "Killing embedded nvim instances: $NVIM_PIDS"
    echo "$NVIM_PIDS" | xargs kill -9 2>/dev/null || true
fi

# Kill orphaned language servers
echo "Cleaning up language server processes..."
for server in yaml-language-server bash-language-server docker-langserver; do
    PIDS=$(pgrep -f "$server" || true)
    if [ -n "$PIDS" ]; then
        echo "  Killing $server: $PIDS"
        echo "$PIDS" | xargs kill -9 2>/dev/null || true
    fi
done

# Clean up copilot processes (these often hang)
COPILOT_PIDS=$(pgrep -f "copilot.*language-server" || true)
if [ -n "$COPILOT_PIDS" ]; then
    echo "Killing copilot language server: $COPILOT_PIDS"
    echo "$COPILOT_PIDS" | xargs kill -9 2>/dev/null || true
fi

# Clean up old log files (keep last 7 days)
echo "Cleaning up old log files..."
find ~/.local/state/nvim -name "*.log" -type f -mtime +7 -delete 2>/dev/null || true

# Clean up swap files older than 7 days
echo "Cleaning up old swap files..."
find ~/.local/state/nvim/swap -type f -mtime +7 -delete 2>/dev/null || true

echo "✅ Cleanup complete!"
echo ""
echo "Remaining nvim processes:"
ps aux | grep "[n]vim" | grep -v grep || echo "  None"
