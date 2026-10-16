#!/bin/sh
# Install / uninstall monitor-layout. Safe to re-run (e.g. after git pull).
#   sh install.sh               link script into ~/.local/bin, install app launchers
#   sh install.sh --uninstall   reverse; keeps saved layouts
#   sh install.sh --purge       uninstall + delete saved layouts
set -eu

SRC=$(cd "$(dirname "$0")" && pwd)
BIN="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"
LINK="$BIN/monitor-layout"
CONF="$HOME/.config/monitor-layout.json"
UNDO="$HOME/.config/monitor-layout-freed.sh"

refresh_menu() {
    # other apps' broken launchers make this noisy; a failure here is harmless
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$APPS" >/dev/null 2>&1 || true
    fi
}

on_path() {
    case ":$PATH:" in *":$BIN:"*) return 0 ;; esac
    return 1
}

# $CMD is how to call the tool right now: plain name if on PATH, else the full path
next_steps() {
    cat <<EOF

next steps:
  1. arrange your screens the way you want them (Settings -> Displays)
  2. save that layout: press Super, type "Monitors", right-click
     "Monitors: Home" and choose "Record current layout as Home";
     a popup then offers a <Super>F key for it
     (terminal instead: $CMD record home)
  3. at your other desk, do the same with "Monitors: Work"
     (terminal: $CMD record work)
  4. switch any time: click a launcher, press the key you picked,
     or run $CMD home / $CMD work
  more commands: $CMD --help
EOF
}

# the shell this was started from (parent process), else the login shell
user_shell() {
    p=$(ps -o comm= -p "$PPID" 2>/dev/null || true)
    case "${p#-}" in
        zsh|bash|fish) echo "${p#-}" ;;
        *)             basename "${SHELL:-sh}" ;;
    esac
}

path_note() {
    line='export PATH="$PATH:$HOME/.local/bin"'
    case "$(user_shell)" in
        zsh)  who=zsh;  cmd="echo '$line' >> ~/.zshrc && source ~/.zshrc" ;;
        bash) who=bash; cmd="echo '$line' >> ~/.bashrc && source ~/.bashrc" ;;
        fish) who=fish; cmd="fish_add_path ~/.local/bin" ;;
        *)    who="other shells"; cmd="echo '$line' >> ~/.profile && . ~/.profile" ;;
    esac
    echo
    echo "note: ~/.local/bin is not in PATH, so the commands above use the full path."
    echo "      Run this once to type just 'monitor-layout' ($who):"
    echo "        $cmd"
    echo "      then try:"
    echo "        monitor-layout --help"
}

uninstall() {
    python3 "$SRC/monitor-layout" --unbind-all || echo "warn: could not remove shortcuts"

    if [ -L "$LINK" ] && [ "$(readlink -f "$LINK")" = "$SRC/monitor-layout" ]; then
        rm "$LINK"
        echo "removed: $LINK"
    elif [ -e "$LINK" ]; then
        echo "kept: $LINK (not a link to this repo)"
    fi

    for f in "$SRC"/desktop/*.desktop; do
        rm -f "$APPS/$(basename "$f")"
    done
    refresh_menu
    echo "removed: launchers"

    if [ "$1" = purge ]; then
        rm -f "$CONF"
        echo "purged: $CONF"
    elif [ -f "$CONF" ]; then
        echo "kept: $CONF (saved layouts; --purge deletes)"
    fi
    # never auto-deleted: it is the only way back for GNOME keys taken with --force
    if [ -f "$UNDO" ]; then
        echo "GNOME keys taken with --force: restore with 'sh $UNDO', then delete it"
    fi
}

case "${1:-}" in
    --uninstall) uninstall keep; exit 0 ;;
    --purge)     uninstall purge; exit 0 ;;
    "")          ;;
    *)           echo "usage: sh install.sh [--uninstall|--purge]" >&2; exit 2 ;;
esac

mkdir -p "$BIN" "$APPS"
chmod 755 "$SRC/monitor-layout" "$SRC/install.sh"
ln -sfn "$SRC/monitor-layout" "$LINK"

for f in "$SRC"/desktop/*.desktop; do
    sed "s|@BIN@|$LINK|g" "$f" > "$APPS/$(basename "$f")"
done
refresh_menu

echo "installed: $LINK -> $SRC/monitor-layout"
echo "launchers: $APPS/monitor-layout-{home,work}.desktop"
if on_path; then CMD=monitor-layout; else CMD='~/.local/bin/monitor-layout'; fi
next_steps
on_path || path_note
if ! command -v zenity >/dev/null 2>&1; then
    echo
    echo "note: popup menu needs zenity: sudo apt install zenity"
fi
