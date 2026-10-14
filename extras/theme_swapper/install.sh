#!/usr/bin/env bash
# Installs theme swapper, Konsole profiles/colorschemes, Nerd Fonts, and fontconfig fallback.
# Usage: ./install.sh   (from anywhere; sudo only asked for the suspend/wake hook)
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
say() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

# 1. Dependencies
say "Checking dependencies"
missing=()
for c in curl jq git nvim; do command -v "$c" >/dev/null || missing+=("$c"); done
if ((${#missing[@]})); then
  if command -v apt >/dev/null; then
    sudo apt install -y curl jq git neovim
  else
    echo "Install missing tools: ${missing[*]}"; exit 1
  fi
fi
python3 -c "import pystray, PIL" 2>/dev/null || {
  say "Installing tray deps (pystray, pillow)"
  if command -v apt >/dev/null; then
    sudo apt install -y python3-pil python3-pystray 2>/dev/null \
      || pip install --user --break-system-packages pystray pillow
  else
    pip install --user pystray pillow
  fi
}

# 2. Scripts
say "Installing scripts to ~/bin"
mkdir -p ~/bin ~/.cache/theme_swapper
install -m 755 "$SRC/bin/theme_swapper.sh" "$SRC/bin/theme_swapper_tray.py" ~/bin/

# 3. Konsole profiles + colorschemes
say "Installing Konsole profiles and colorschemes"
mkdir -p ~/.local/share/konsole
cp "$SRC"/konsole/* ~/.local/share/konsole/
if command -v kwriteconfig6 >/dev/null; then
  kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile mm_dark.profile
elif command -v kwriteconfig5 >/dev/null; then
  kwriteconfig5 --file konsolerc --group "Desktop Entry" --key DefaultProfile mm_dark.profile
fi

# 4. Nerd Fonts + fallback
FONT_DIR=~/.local/share/fonts/nerd
if ! fc-list | grep -q "Symbols Nerd Font Mono"; then
  say "Downloading Nerd Fonts (FiraCode + Symbols)"
  mkdir -p "$FONT_DIR"
  tmp=$(mktemp -d)
  for f in FiraCode NerdFontsSymbolsOnly; do
    curl -fsSL -o "$tmp/$f.tar.xz" \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$f.tar.xz"
    tar -xJf "$tmp/$f.tar.xz" -C "$FONT_DIR" --wildcards '*.ttf'
  done
  rm -rf "$tmp"
fi
mkdir -p ~/.config/fontconfig/conf.d
cp "$SRC/fontconfig/50-nerd-symbols.conf" ~/.config/fontconfig/conf.d/
fc-cache -f >/dev/null

# 5. systemd timer
say "Enabling theme-swapper timer"
mkdir -p ~/.config/systemd/user
cp "$SRC"/systemd/theme-swapper.{service,timer} ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now theme-swapper.timer

# 6. Tray autostart
say "Adding tray to autostart"
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/theme-swapper-tray.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=$HOME/bin/theme_swapper_tray.py
Name=Theme Swapper Tray
Comment=Tray icon for Theme Swapper
X-GNOME-Autostart-enabled=true
EOF

# 7. Re-run after resume from sleep (needs sudo)
HOOK=/usr/lib/systemd/system-sleep/theme_swapper_wake.sh
say "Installing wake hook at $HOOK (sudo)"
sudo tee "$HOOK" >/dev/null <<EOF
#!/bin/bash
case "\$1" in
  post)
    sudo -u $USER DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus \\
      systemctl --user start theme-swapper.service
    ;;
esac
EOF
sudo chmod 755 "$HOOK"

# 8. Neovim plugins + apply theme now
say "Syncing Neovim plugins"
nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || true
~/bin/theme_swapper.sh force || true

say "Done. Restart Konsole to pick up the font."
