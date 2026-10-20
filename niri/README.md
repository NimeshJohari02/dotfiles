# Niri setup

This directory contains a split Niri config for CachyOS with Noctalia. To use it, copy this directory's contents into `~/.config/niri/`.

`Super` is the Windows key. Highlights:

- `Super + Enter`: terminal; `Super + B`: Zen Browser; `Super + Space`: Noctalia launcher.
- `Super + Up/Down`: switch workspaces; `Super + 1` through `9`: jump to a workspace.
- `Super + Shift + Up/Down`: move the focused column to another workspace; `Super + Shift + 1` through `9`: move it to a numbered workspace.
- `Super + Shift + Left/Right`: move the focused column to another monitor.
- `Print`: open Niri's interactive screenshot UI.
- `Super + V`: start/stop [local voice dictation](../dictation/README.md); `Super + Shift + V`: clipboard history.
- Caps Lock and Escape are swapped in `cfg/input.kdl`.

Niri's config has `focus-follows-mouse` enabled, so moving the pointer to another monitor moves focus there. No keyboard shortcut is currently assigned to focus another monitor without moving a window. From a terminal, run `niri msg action focus-monitor-left` or `niri msg action focus-monitor-right` to focus the adjacent monitor; those actions can also be bound to keys.

The main file is `config.kdl`; it includes the settings in `cfg/`. Niri reloads valid config edits automatically. Check the config with `niri validate`.

`cfg/autostart.kdl` starts Noctalia and the KDE Connect background daemon at login.
See [Noctalia setup](../noctalia/README.md) to enable the phone tile on `Super + S`.
