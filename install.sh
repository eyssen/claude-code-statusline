#!/bin/bash

# Claude Code Statusline - Installer
# https://github.com/kalmarr-dev/claude-code-statusline

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SOURCE_SCRIPT="$SCRIPT_DIR/statusline.sh"
TARGET_SCRIPT="$CLAUDE_DIR/statusline.sh"

echo "=== Claude Code Statusline Installer ==="
echo ""

# Check dependencies
for cmd in jq bash git; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "[OK] $cmd found"
    else
        if [ "$cmd" = "git" ]; then
            echo "[WARN] $cmd not found (optional - git branch info won't work)"
        else
            echo "[ERROR] $cmd not found. Please install it first."
            exit 1
        fi
    fi
done
echo ""

# Create ~/.claude/ if it doesn't exist
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "Creating $CLAUDE_DIR..."
    mkdir -p "$CLAUDE_DIR"
fi

# Copy statusline.sh
if [ -f "$TARGET_SCRIPT" ]; then
    echo "[WARN] $TARGET_SCRIPT already exists."
    if [ ! -t 0 ]; then
        answer="y"
    else
        read -rp "Overwrite? [y/N] " answer
    fi
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo "Skipping file copy."
    else
        cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
        echo "[OK] Copied statusline.sh to $TARGET_SCRIPT"
    fi
else
    cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
    echo "[OK] Copied statusline.sh to $TARGET_SCRIPT"
fi

# Make executable
chmod +x "$TARGET_SCRIPT"
echo "[OK] Made executable"

# Configure settings.json
if [ -f "$SETTINGS_FILE" ]; then
    # Check if statusLine is already configured
    if jq -e '.statusLine' "$SETTINGS_FILE" >/dev/null 2>&1; then
        echo ""
        echo "[INFO] statusLine is already configured in $SETTINGS_FILE:"
        jq '.statusLine' "$SETTINGS_FILE"
        echo ""
        echo "No changes made to settings. Edit manually if needed."
    else
        # Add statusLine config
        tmp=$(mktemp)
        jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
        echo "[OK] Added statusLine config to $SETTINGS_FILE"
    fi
else
    # Create settings.json with statusLine config
    echo '{"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' | jq . > "$SETTINGS_FILE"
    echo "[OK] Created $SETTINGS_FILE with statusLine config"
fi

echo ""
echo "=== Installation complete! ==="
echo ""
echo "Restart Claude Code to see the statusline."
echo "To enable debug mode: DEBUG=1 claude"
