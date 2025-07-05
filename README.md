# Capslock Alert

A tiny script that shows a persistent desktop notification when **Caps Lock** is enabled.

Ideal for laptops or keyboards without a Caps Lock LED.

---

## 🔧 Requirements

The install script will try to install all required dependencies automatically.

If you want to install them manually, here's how:

**Arch Linux:**

```bash
sudo pacman -S evtest libnotify dunst python-evdev
```

**Debian / Ubuntu:**

```bash
sudo apt install evtest libnotify-bin dunst python3-evdev
```

---

## 🚀 Installation

Clone the repo and run the install script:

```bash
git clone https://github.com/YOURNAME/capslock-alert.git
cd capslock-alert
./install.sh
```

The installation script will set up the necessary files and automatically enable the systemd user service for Caps Lock notifications.

Then toggle **Caps Lock** — you should see a red notification.

To remove it later:

```bash
./uninstall.sh
```

This script will disable the systemd service and remove all installed files.

---

## 🔄 What it does

* Watches for Caps Lock LED changes using `evtest`
* When Caps Lock is ON, shows a red notification
* When Caps Lock is OFF, closes the notification
* Rescans devices periodically to handle hotplugged keyboards
* Maintains a log file for events at `~/.local/state/capslock-alert.log`
* Runs as a systemd user service

---

## 🛠 Troubleshooting

* **No notification?** Test with `notify-send "test"`
* **Missing permissions?** Make sure your user can read `/dev/input/event*`
* **Script crashes?** Check the log file:

  ```bash
  cat ~/.local/state/capslock-alert.log
  ```

* **Notification not appearing?** Ensure Dunst is running. If Dunst isn't reloading automatically, restart it manually.

