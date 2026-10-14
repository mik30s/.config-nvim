#!/usr/bin/env python3
import os
import subprocess
from PIL import Image, ImageDraw
import pystray
from pystray import MenuItem as item

# Paths
LOCK_FILE = os.path.expanduser("~/.cache/theme_swapper/disabled")
SCRIPT_PATH = os.path.expanduser("~/bin/theme_swapper.sh")

def create_image(color):
    # Generate a simple icon
    image = Image.new('RGB', (64, 64), color)
    dc = ImageDraw.Draw(image)
    dc.ellipse((8, 8, 56, 56), fill=(255, 255, 255), outline=(0, 0, 0))
    return image

def is_disabled():
    return os.path.exists(LOCK_FILE)

def toggle_disabled(icon, item):
    if is_disabled():
        os.remove(LOCK_FILE)
    else:
        with open(LOCK_FILE, "w") as f:
            f.write("disabled")
    # Refresh the menu
    icon.update_menu()

def run_manual(mode):
    subprocess.run([SCRIPT_PATH, mode])

def on_exit(icon, item):
    icon.stop()

# Define the menu
menu = pystray.Menu(
    item(
        "Theme Swapper Enabled",
        toggle_disabled,
        checked=lambda item: not is_disabled()
    ),
    pystray.Menu.SEPARATOR,
    item("Switch to Light", lambda: run_manual("light")),
    item("Switch to Dark", lambda: run_manual("dark")),
    item("Auto (Sync Now)", lambda: subprocess.run([SCRIPT_PATH, "force"])),
    pystray.Menu.SEPARATOR,
    item("Exit", on_exit)
)

# Create the icon
icon = pystray.Icon(
    "theme_swapper",
    create_image("blue"),
    "Theme Swapper",
    menu
)

if __name__ == "__main__":
    icon.run()
