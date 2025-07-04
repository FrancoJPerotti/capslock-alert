# Capslock‑Alert

Tiny user‑level daemon that pops up a persistent desktop notification whenever **Caps Lock** is on. Perfect for laptops without a CapsLock LED — and for anyone who keeps "SHOUTING" by accident.

![demo gif](docs/demo.gif)

---

## Features

* **Lightweight** – pure Bash + `evtest`, no polling loops
* **Zero root** – runs as a per‑user `systemd` service
* **Desktop‑agnostic** – works with Dunst, GNOME, KDE, swaync, etc.
* **Auto‑recovers** after suspend or keyboard re‑plug
* **Logs** to `~/.local/state/capslock-alert.log` (XDG‑compliant)
* One‑command **install** and **uninstall** scripts

---

## Prerequisites

| Component              | Arch                        | Debian / Ubuntu                   | Fedora                        |
| ---------------------- | --------------------------- | --------------------------------- | ----------------------------- |
| `evtest`               | `pacman -S evtest`          | `apt install evtest`              | `dnf install evtest`          |
| `notify-send` + daemon | `pacman -S libnotify dunst` | `apt install libnotify-bin dunst` | `dnf install libnotify dunst` |

> Any freedesktop‑compatible notification daemon works. Replace **Dunst** with your favourite if needed.

---

## Quick install (per‑user)

```bash
git clone https://github.com/YOURNAME/capslock-alert.git
cd capslock-alert
./install.sh    # copies files and enables the service
```

Toggle **Caps Lock** – you should see a persistent red pop‑up.

### Uninstall

```bash
./uninstall.sh
```

---

## Manual install (no helper scripts)

```bash
# 1. Copy files
mkdir -p ~/.local/bin ~/.config/systemd/user
cp capslock-alert.sh      ~/.local/bin/
cp capslock-alert.service ~/.config/systemd/user/

# 2. Enable the service
systemctl --user daemon-reload
systemctl --user enable --now capslock-alert.service
```

---

## Customisation

| Want to…                                    | Edit                                                                      |
| ------------------------------------------- | ------------------------------------------------------------------------- |
| Use **Num Lock** or **Scroll Lock** instead | Replace `LED_CAPSL` with `LED_NUML` / `LED_SCROLL` in *capslock-alert.sh* |
| Monitor **multiple keyboards**              | Iterate over every `/dev/input/event*` that advertises `LED_CAPSL`        |
| Change notification text / urgency          | Tweak the `notify-send` and `dunstctl` lines                              |
| Package for other distros                   | See `packaging/arch/PKGBUILD` for inspiration; PRs welcome!               |

---

## Troubleshooting

| Symptom                                       | Explanation / Fix                                                                                                                |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| *Cannot find keyboard device*                 | Your keyboard may not create a `*-kbd` symlink. Adjust the `find` glob or point the script to `/dev/input/eventX`.               |
| No notification appears                       | Verify your notification daemon: `notify-send test`. Then inspect logs: `journalctl --user -u capslock-alert -f`.                |
| Permission denied opening `/dev/input/eventX` | Ensure your session grants read access (logind usually does). Otherwise add your user to the `input` group or write a udev rule. |

---

## Contributing

Pull requests and issue reports are welcome! Please run `shellcheck capslock-alert.sh` before pushing.

---

## License

MIT – see [`LICENSE`](LICENSE) for details.
