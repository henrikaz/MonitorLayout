# monitor-layout

Save and switch monitor layouts (e.g. home / work) on GNOME, X11 or Wayland, via Mutter's D-Bus API.

Monitors are matched by EDID (vendor / product / serial), not connector name. Connector names
change with GPU mode, dock and port (`DP-2`, `DP-1-1`, `HDMI-1-0` ...), which is why GNOME's own
`~/.config/monitors.xml` often fails to restore a known setup.

## Install

```bash
git clone <repo> ~/Development/MonitorLayout
sh ~/Development/MonitorLayout/install.sh
```

`install.sh` links the script to `~/.local/bin/monitor-layout` and installs two app launchers,
**Monitors: Home** and **Monitors: Work** (right-click: *Record current layout*). Re-run it after `git pull`.

Requires: GNOME, `python3-gi` (default on Ubuntu). Optional: `zenity` (popup menu), `notify-send`.

## Usage

```
monitor-layout NAME            apply layout (auto if not recorded)
monitor-layout NAME N          shortcut <Super>F<N> -> NAME (N=0 removes)
monitor-layout NAME N --force  take the key from GNOME (undo: sh ~/.config/monitor-layout-freed.sh)
monitor-layout NAME auto       shortcut on first F-key GNOME doesn't use
monitor-layout NAME free       menu: pick shortcut F-key
monitor-layout record NAME     save current layout as NAME, then key menu
monitor-layout keys            which <Super>F1..F12 are free
monitor-layout --list          monitors, layouts, shortcuts
  --dry-run  show plan only
  --save     make GNOME remember it (asks "Keep changes?")
```

Typical setup:

```bash
# arrange screens in Settings -> Displays, then:
monitor-layout record home     # saves layout, then pick a Super+F key
# at work:
monitor-layout record work
```

A name without a recording uses the auto layout: laptop on top (centered), external monitors in a
row below, USB-C/DP left, HDMI right.

## Files

| Path | What |
|---|---|
| `~/.config/monitor-layout.json` | recorded layouts (not in repo) |
| `~/.config/monitor-layout-freed.sh` | undo for keys taken with `--force` |
| `~/.local/bin/monitor-layout` | symlink to this repo |
| `~/.local/share/applications/monitor-layout-*.desktop` | launchers |

Shortcuts are GNOME custom keybindings (Settings -> Keyboard -> Custom Shortcuts).

## Uninstall

```bash
for n in home work; do monitor-layout $n 0; done   # remove shortcuts
rm ~/.local/bin/monitor-layout ~/.local/share/applications/monitor-layout-*.desktop
```
