#!/usr/bin/env python3
import asyncio
import os
import subprocess
import sys
import time

import evdev

NOTIF_ID = "22222"
ON_MSG = " CAPSLOCK"
OFF_CMD = ["dunstctl", "close", NOTIF_ID]
SEND_CMD = ["notify-send", "-u", "critical", "-r", NOTIF_ID, "-c", "capslock", ON_MSG]

SCAN_PERIOD = 5  # seconds between hot-plug rescans
LOG = os.path.expanduser("~/.local/state/capslock-alert.log")


def log(msg):
    with open(LOG, "a") as f:
        print(time.strftime("%F %T"), msg, file=f)


def caps_led(dev):
    """True if device has LED_CAPSL capability"""
    return (
        evdev.ecodes.EV_LED in dev.capabilities()
        and evdev.ecodes.LED_CAPSL in dev.capabilities()[evdev.ecodes.EV_LED]
    )


async def watch(dev):
    """Async generator of LED_CAPSL events for one device"""
    async for ev in dev.async_read_loop():
        if ev.type == evdev.ecodes.EV_LED and ev.code == evdev.ecodes.LED_CAPSL:
            yield ev.value  # 1 = on, 0 = off


async def monitor():
    last_state = None
    tasks = {}

    async def rescan():
        nonlocal tasks
        cur = {
            d.path: d
            for d in map(evdev.InputDevice, evdev.list_devices())
            if caps_led(d)
        }
        # add new
        for path, dev in cur.items():
            if path not in tasks:
                log(f"+ device {path}")
                tasks[path] = asyncio.create_task(watch_device(dev))
        # remove gone
        for path in list(tasks):
            if path not in cur:
                log(f"- device {path}")
                tasks[path].cancel()
                del tasks[path]

    async def watch_device(dev):
        async for val in watch(dev):
            nonlocal last_state
            if val == 1 and last_state != 1:
                subprocess.run(SEND_CMD)
                last_state = 1
                log("CAPS ON")
            elif val == 0 and last_state != 0:
                subprocess.run(OFF_CMD)
                last_state = 0
                log("CAPS OFF")

    while True:
        await rescan()
        await asyncio.sleep(SCAN_PERIOD)


if __name__ == "__main__":
    log("=== capslock-alert started ===")
    try:
        asyncio.run(monitor())
    except KeyboardInterrupt:
        sys.exit(0)
