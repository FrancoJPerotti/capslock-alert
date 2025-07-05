#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="$HOME/.local/bin"
UNIT_DIR="$HOME/.config/systemd/user"
DUNST_DIR="$HOME/.config/dunst"
DUNSTRC="$DUNST_DIR/dunstrc"

SCRIPT_NAME="capslock-alert.py"
UNIT_NAME="capslock-alert.service"
RULE_FILE="capslock.rule" # just the rule
FALLBACK_RC="dunstrc.min" # starter rc if user has none

EXEC_DEPS=(python3 notify-send dunstctl evtest) # binaries
PY_DEPS=(evdev)                                 # python modules

# ---------------------------------------------------------------
echo "→ Checking/Installing dependencies…"

missing=()

# executables
for cmd in "${EXEC_DEPS[@]}"; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
done

# python modules
for mod in "${PY_DEPS[@]}"; do
    python3 - <<EOF || missing+=("python-$mod")
import importlib, sys
sys.exit(0 if importlib.util.find_spec("$mod") else 1)
EOF
done

if ((${#missing[@]})); then
    echo "⚠️  Missing: ${missing[*]}"
    read -rp "Install them now? [y/N]: " ans
    if [[ ${ans,,} == y ]]; then
        if command -v pacman &>/dev/null; then
            sudo pacman -S --needed "${missing[@]}"
        elif command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y "${missing[@]}"
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y "${missing[@]}"
        else
            echo "❌ Unsupported pkg manager. Abort."
            exit 1
        fi
    fi
fi

# ---------------------------------------------------------------
echo "→ Copying daemon + unit…"
install -Dm755 "$SCRIPT_NAME" "$TARGET_DIR/$SCRIPT_NAME"
install -Dm644 "$UNIT_NAME" "$UNIT_DIR/$UNIT_NAME"
systemctl --user daemon-reload
systemctl --user enable --now "$UNIT_NAME"

# ---------------------------------------------------------------
echo "→ Ensuring dunst config…"
mkdir -p "$DUNST_DIR"

if [[ ! -f $DUNSTRC ]]; then
    echo "   • No dunstrc found → installing fallback."
    install -m644 "$FALLBACK_RC" "$DUNSTRC"
fi

# inject rule only once
if ! grep -Fq "[rule_capslock]" "$DUNSTRC"; then
    echo "   • Adding Caps-Lock rule to dunstrc."
    {
        echo -e "\n# Auto-added by capslock-alert"
        cat "$RULE_FILE"
    } >>"$DUNSTRC"
else
    echo "   • Caps-Lock rule already present."
fi

# ---------------------------------------------------------------
echo "→ Reloading dunst (if running)…"
if command -v dunstctl &>/dev/null && pgrep -x dunst &>/dev/null; then
    dunstctl reload && echo "   • dunst reloaded"
else
    echo "   • dunst is not running or dunstctl missing; restart it manually."
fi

echo "✅ Installation complete. Press Caps Lock to test!"
