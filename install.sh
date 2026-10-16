#!/bin/sh
# Install monitor-layout: link script into ~/.local/bin, install app launchers.
# Safe to re-run (e.g. after git pull). Run as: sh install.sh
set -eu

SRC=$(cd "$(dirname "$0")" && pwd)
BIN="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"

mkdir -p "$BIN" "$APPS"
chmod 755 "$SRC/monitor-layout" "$SRC/install.sh"
ln -sfn "$SRC/monitor-layout" "$BIN/monitor-layout"

for f in "$SRC"/desktop/*.desktop; do
    sed "s|@BIN@|$BIN/monitor-layout|g" "$f" > "$APPS/$(basename "$f")"
done
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" || true

echo "installed: $BIN/monitor-layout -> $SRC/monitor-layout"
echo "launchers: $APPS/monitor-layout-{home,work}.desktop"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "note: $BIN is not in PATH" ;; esac
command -v zenity >/dev/null 2>&1 || echo "note: popup menu needs zenity: sudo apt install zenity"
