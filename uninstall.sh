#!/usr/bin/env bash
set -euo pipefail

UNIT_DIR="$HOME/.config/systemd/user"
TARGET_DIR="$HOME/.local/bin"

systemctl --user disable --now capslock-alert.service || true
rm -f "$UNIT_DIR/capslock-alert.service"
rm -f "$TARGET_DIR/capslock-alert.py"
systemctl --user daemon-reload

echo "✓ capslock-alert removed."
