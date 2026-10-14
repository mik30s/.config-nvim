#!/bin/bash
# Theme Swapper Script for KDE, Konsole, Neovim, and Firefox

# San Diego Coordinates
LAT="32.7157"
LNG="-117.1611"

CACHE_DIR="$HOME/.cache/theme_swapper"
mkdir -p "$CACHE_DIR"

# 1. Check if disabled
if [ -f "$CACHE_DIR/disabled" ] && [ "$1" != "light" ] && [ "$1" != "dark" ] && [ "$1" != "force" ]; then
    exit 0
fi

# 2. Get Sunrise/Sunset (with caching to avoid API spam)
DATE_STAMP=$(date +%Y-%m-%d)
CACHE_FILE="$CACHE_DIR/sun_times_$DATE_STAMP"

if [ -f "$CACHE_FILE" ]; then
    DATA=$(cat "$CACHE_FILE")
else
    DATA=$(curl -s "https://api.sunrise-sunset.org/json?lat=$LAT&lng=$LNG&formatted=0")
    if [ $? -eq 0 ] && [ "$(echo "$DATA" | jq -r .status 2>/dev/null)" = "OK" ]; then
        echo "$DATA" > "$CACHE_FILE"
        # Clean up old cache files
        find "$CACHE_DIR" -name "sun_times_*" -not -name "sun_times_$DATE_STAMP" -delete
    fi
fi

# 3. Determine Mode
if [ "$1" = "light" ] || [ "$1" = "dark" ]; then
    MODE="$1"
else
    if [ -f "$CACHE_FILE" ]; then
        SUNRISE=$(date -d "$(echo "$DATA" | jq -r .results.sunrise)" +%s)
        SUNSET=$(date -d "$(echo "$DATA" | jq -r .results.sunset)" +%s)
        NOW=$(date +%s)
        if [ "$NOW" -ge "$SUNRISE" ] && [ "$NOW" -lt "$SUNSET" ]; then
            MODE="light"
        else
            MODE="dark"
        fi
    else
        # Fallback if API and Cache fail
        HOUR=$(date +%H)
        if [ "${HOUR#0}" -ge 6 ] && [ "${HOUR#0}" -lt 18 ]; then
            MODE="light"
        else
            MODE="dark"
        fi
    fi
fi

# 4. Only change if mode has actually changed (or if forced)
LAST_MODE_FILE="$CACHE_DIR/last_applied_mode"
if [ -f "$LAST_MODE_FILE" ]; then
    LAST_MODE=$(cat "$LAST_MODE_FILE")
fi

if [ "$MODE" = "$LAST_MODE" ] && [ "$1" != "force" ]; then
    # No change needed
    exit 0
fi

# 5. Apply Themes
if [ "$MODE" = "light" ]; then
    KDE_THEME="org.kde.breeze.desktop"
    GTK_THEME="Breeze"
    COLOR_SCHEME="prefer-light"
    KONSOLE_THEME="SumacDay"
    NVIM_THEME="light"
else
    KDE_THEME="org.kde.breezedark.desktop"
    GTK_THEME="Breeze-Dark"
    COLOR_SCHEME="prefer-dark"
    KONSOLE_THEME="SumacNight"
    NVIM_THEME="dark"
fi

# Apply KDE Global Theme
lookandfeeltool -a "$KDE_THEME" || true

# Apply GTK Theme
gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME" || true
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" || true

# Apply Konsole Theme to Profiles
for f in "$HOME"/.local/share/konsole/*.profile; do
    [ -e "$f" ] && sed -i "s/^ColorScheme=.*/ColorScheme=$KONSOLE_THEME/" "$f"
done

# Apply Konsole Theme to Running Sessions
for tty in /dev/pts/[0-9]*; do
    if [ -w "$tty" ]; then
        printf "\033]50;ColorScheme=%s\a" "$KONSOLE_THEME" > "$tty" 2>/dev/null
    fi
done

# Update Neovim Cache
echo "$MODE" > "$HOME/.cache/theme_mode"

# Signal Running Neovim Instances
USER_ID=$(id -u)
for sock in /run/user/"$USER_ID"/nvim.*.0; do
    if [ -S "$sock" ]; then
        nvim --server "$sock" --remote-send "<C-\><C-n>:NeonTheme $NVIM_THEME<CR>" 2>/dev/null
    fi
done

# Store the fact that we applied this mode
echo "$MODE" > "$LAST_MODE_FILE"

exit 0
