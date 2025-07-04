# Capslock Alert

A tiny script that shows a persistent desktop notification when **Caps Lock** is enabled.

Ideal for laptops or keyboards without a Caps Lock LED.

---

## 🔧 Requirements

The install script will try to install all required dependencies automatically.

If you want to install them manually, here's how:

**Arch Linux:**

```bash
sudo pacman -S evtest libnotify dunst
```

**Debian / Ubuntu:**

```bash
sudo apt install evtest libnotify-bin dunst
```

---

## 🚀 Installation

Clone the repo and run the install script:

```bash
git clone https://github.com/YOURNAME/capslock-alert.git
cd capslock-alert
./install.sh
```

Then toggle **Caps Lock** — you should see a red notification.

To remove it later:

```bash
./uninstall.sh
```

---

## 🔄 What it does

* Watches for Caps Lock LED changes using `evtest`
* When Caps Lock is ON, shows a red notification
* When Caps Lock is OFF, closes the notification
* Runs as a systemd user service

---

## 🛠 Troubleshooting

* **No notification?** Test with `notify-send "test"`
* **Missing permissions?** Make sure your user can read `/dev/input/event*`
* **Script crashes?** Check the log file:

  ```bash
  cat ~/.local/state/capslock-alert.log
  ```

---

## 📄 License

MIT – free to use and modify.
