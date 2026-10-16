# monitor-layout

**One key, right screens — home or work.** Your monitors, remembered by serial number, not by port.

Save your monitor arrangements on GNOME and switch between them with a click, a keyboard shortcut or a
single command. Works on X11 and Wayland through Mutter's D-Bus API.

## Why

Connector names (`DP-2`, `DP-1-1`, `HDMI-1-0`, ...) change with the GPU mode, the dock and the port, which
is why GNOME's own `~/.config/monitors.xml` often fails to restore a known setup. `monitor-layout` matches
monitors by EDID (vendor, product, serial) instead, so a recorded layout keeps working whichever port or
dock the monitors are plugged into.

## Features

- **Named layouts.** Record the current arrangement as `home`, `work` or any other name. Position, scale,
  rotation, primary monitor, resolution and refresh rate are saved for every monitor.
- **Three ways to switch.** App-menu launchers, keyboard shortcuts (`Super+F1` to `Super+F12`) or the terminal.
- **Safe shortcuts.** A key is checked against all of GNOME's own shortcuts and is never taken silently.
- **Automatic layout.** A name you have not recorded still works: laptop on top, external monitors in a row below.
- **Nothing running in the background.** A script, two launchers and standard GNOME custom shortcuts.

## Requirements

- GNOME, on X11 or Wayland
- Python 3 with PyGObject (`python3-gi`, installed by default on Ubuntu)
- Optional: `zenity` (the shortcut-key popup when used without a terminal) and `notify-send` (desktop notifications)

## Installation

```bash
git clone https://github.com/henrikaz/MonitorLayout.git ~/Development/MonitorLayout
sh ~/Development/MonitorLayout/install.sh
```

The installer links the script to `~/.local/bin/monitor-layout`, adds two app launchers, **Monitors: Home**
and **Monitors: Work**, and prints the next steps. It is safe to re-run, for example after `git pull`.

For the shortcut-key popup, install zenity: `sudo apt install zenity`.

## Quick start

Installing takes one terminal command. After that you can work entirely from the desktop, or use the
terminal if you prefer.

### Without a terminal

1. Arrange your screens the way you want them in **Settings → Displays**.
2. Press `Super` and type **Monitors**. The launchers **Monitors: Home** and **Monitors: Work** appear.
3. **Right-click** *Monitors: Home* and choose **Record current layout as Home**. A popup then offers a
   shortcut key (`Super+F1` to `Super+F12`); pick one, or cancel to skip.
4. At your other desk, do the same with *Monitors: Work*.
5. To switch, **click** a launcher or press its shortcut. A notification confirms each action.

### From the terminal

```bash
# arrange your screens in Settings → Displays, then:
monitor-layout record home    # saves the layout, then offers a Super+F key
# at your other desk:
monitor-layout record work
# any time later:
monitor-layout home           # or: monitor-layout work
```

In a terminal the key picker is a text menu; without one it is a popup.

## Tips

- **Pin the launchers.** Right-click *Monitors: Home* and choose **Add to Favorites** to switch with one
  click from the dash.
- **Preview first.** `monitor-layout home --dry-run` shows what would happen, which monitor goes where and
  which are switched off, without changing anything.
- **Works before you record.** An unrecorded name uses the automatic layout, so `monitor-layout home` is
  useful from day one.
- **More than two layouts.** `monitor-layout record desk`, then `monitor-layout desk auto` to give it the
  first free shortcut. The launchers cover Home and Work only. Keep names simple: letters, digits, `-` and `_`.
- **See what is connected.** `monitor-layout --list` shows each monitor's vendor, product and serial, the
  recorded layouts and the shortcuts.
- **Make GNOME remember a layout.** Add `--save` and GNOME asks "Keep changes?". Without it, GNOME applies
  the layout but does not store it.

## Command reference

| Command | What it does |
|---|---|
| `monitor-layout NAME` | Apply layout `NAME` (the automatic layout if it has not been recorded) |
| `monitor-layout record NAME` | Save the current arrangement as `NAME`, then choose a shortcut key |
| `monitor-layout NAME N` | Bind `Super+F<N>` to `NAME` (`N` = 0 removes the shortcut) |
| `monitor-layout NAME auto` | Bind the first `Super+F` key that nothing else uses |
| `monitor-layout NAME free` | Choose the shortcut key from a menu |
| `monitor-layout NAME N --force` | Take key `N` from GNOME if it is in use (see [Keyboard shortcuts](#keyboard-shortcuts)) |
| `monitor-layout keys` | Show which of `Super+F1` to `Super+F12` are free |
| `monitor-layout --list` | Show monitors, recorded layouts and shortcuts |
| `monitor-layout --unbind-all` | Remove every shortcut created by this tool |
| `monitor-layout --help` | Show usage |

Options: `--dry-run` shows the plan and changes nothing; `--save` makes GNOME remember the layout.

## Keyboard shortcuts

Shortcuts are GNOME custom shortcuts named *Monitors: NAME* (Settings → Keyboard → Custom Shortcuts).
Before binding a key, the tool checks it against every shortcut GNOME knows about: shell, window manager,
media keys, extensions and your other custom shortcuts. A key that is in use is refused unless you pass
`--force`, which frees it from the other setting and records how to undo that in
`~/.config/monitor-layout-freed.sh`. To give GNOME its keys back: `sh ~/.config/monitor-layout-freed.sh`.

## Files

| Path | Purpose |
|---|---|
| `~/.config/monitor-layout.json` | Recorded layouts (not part of this repository) |
| `~/.config/monitor-layout-freed.sh` | Undo script for keys taken with `--force` |
| `~/.local/bin/monitor-layout` | Symlink to the script in this repository |
| `~/.local/share/applications/monitor-layout-*.desktop` | App-menu launchers |

## Troubleshooting

**`monitor-layout: command not found`.** `~/.local/bin` is not on your `PATH`. The launchers and shortcuts
work regardless. To use the command in a terminal, run the line for your shell once (the installer prints it):

| Shell | Command |
|---|---|
| zsh | `echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc && source ~/.zshrc` |
| bash | `echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc && source ~/.bashrc` |
| fish | `fish_add_path ~/.local/bin` |
| other | `echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.profile && . ~/.profile` |

**`Not connected: ...`.** A monitor from the recorded layout is not plugged in. Connect it, or record the
layout again with the monitors you have now.

**A shortcut key is already in use.** Pick another key (`monitor-layout keys` shows the free ones) or add
`--force`.

**No shortcut popup after recording.** Install `zenity` (`sudo apt install zenity`). The layout itself is
saved either way.

**A launcher seems to do nothing.** Run the same command in a terminal, for example `monitor-layout home`,
to see the error message.

## Uninstall

```bash
sh ~/Development/MonitorLayout/install.sh --uninstall   # keeps saved layouts
sh ~/Development/MonitorLayout/install.sh --purge       # also deletes saved layouts
```

This removes the tool's shortcuts, the `~/.local/bin` link (only if it points to this repository) and the
launchers. The repository itself is untouched. The `--force` undo file is never deleted automatically: run
`sh ~/.config/monitor-layout-freed.sh` to give GNOME its keys back, then delete it.

## License and credits

Written by Henrikas Norvaisa ([@henrikaz](https://github.com/henrikaz)) and released under the
[MIT License](LICENSE): free to use, copy, modify and share, as long as the copyright notice stays with it.
It comes with no warranty of any kind.

`monitor-layout` uses GNOME's Mutter `DisplayConfig` D-Bus API through PyGObject, and optionally `zenity` and
`notify-send`. None of their code is included in this repository.
