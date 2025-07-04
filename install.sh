#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$HOME/.local/bin"
UNIT_DIR="$HOME/.config/systemd/user"
SCRIPT_NAME="capslock-alert.sh"
UNIT_NAME="capslock-alert.service"

# Required commands
DEPS=(evtest notify-send dunstctl)

# Function to detect package manager and install missing deps
install_deps() {
    echo "→ Checking for required dependencies..."
    missing=()
    for cmd in "${DEPS[@]}"; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done

    if ((${#missing[@]} == 0)); then
        echo "✓ All dependencies are installed."
        return
    fi

    echo "⚠️  Missing dependencies: ${missing[*]}"
    read -rp "❓ Try to install them now? [y/N]: " confirm
    [[ "${confirm,,}" != "y" ]] && return

    if command -v pacman &>/dev/null; then
        sudo pacman -S --needed "${missing[@]}"
    elif command -v apt &>/dev/null; then
        sudo apt update
        sudo apt install -y "${missing[@]}"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "${missing[@]}"
    else
        echo "❌ Unsupported package manager. Please install the following manually:"
        echo "   ${missing[*]}"
    fi
}

echo "→ Installing capslock-alert…"
install_deps

mkdir -p "$TARGET_DIR" "$UNIT_DIR"
install -m 755 "$SCRIPT_NAME" "$TARGET_DIR/"
install -m 644 "$UNIT_NAME" "$UNIT_DIR/"

systemctl --user daemon-reload
systemctl --user enable --now "$UNIT_NAME"

echo "✓ Done! The service is now active. Toggle Caps Lock to test it."
