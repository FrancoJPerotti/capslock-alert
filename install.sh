#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$HOME/.local/bin"
UNIT_DIR="$HOME/.config/systemd/user"

echo "→ Installing capslock-alert…"

mkdir -p "$TARGET_DIR" "$UNIT_DIR"
install -m 755 capslock-alert.sh "$TARGET_DIR/"
install -m 644 capslock-alert.service "$UNIT_DIR/"

systemctl --user daemon-reload
systemctl --user enable --now capslock-alert.service

echo "✓ Done! You should now see a notification when Caps Lock is ON."
