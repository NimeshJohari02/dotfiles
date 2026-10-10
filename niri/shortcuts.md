# Niri shortcuts

`Super` means the Windows key.

| Shortcut | Action |
|---|---|
| `Super + Enter` | Open Alacritty |
| `Super + Space` | Open the Noctalia application launcher |
| `Super + B` | Open Zen Browser |
| `Super + E` | Open Nautilus |
| `Super + O` | Toggle Niri overview |
| `Super + Shift + Esc` | Show Niri shortcut overlay |
| `Print` | Open interactive screenshot UI |
| `Super + Up/Down` | Switch to workspace above/below |
| `Super + 1` … `Super + 9` | Switch to workspace 1–9 |
| `Super + Shift + Up/Down` | Move focused column to workspace above/below |
| `Super + Shift + 1` … `Super + Shift + 9` | Move focused column to workspace 1–9 |
| `Super + Shift + Left/Right` | Move focused column to monitor left/right |
| `Super + Left/Right` | Focus column left/right |
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + M` | Maximize window to edges |
| `Super + F` | Maximize column |
| `Super + Shift + F` | Fullscreen window |
| `Super + T` | Toggle floating window |
| `Super + Q` | Close focused window |
| `Super + S` | Open Noctalia control center |
| `Super + Shift + S` | Open Noctalia settings |
| `Super + Alt + L` | Lock screen |
| `Super + Shift + Q` | Open session menu |
| `XF86MonBrightnessUp/Down` | Adjust brightness on the current monitor |

Caps Lock and Escape are swapped. Monitor focus follows the pointer. To move monitor focus from a terminal without moving a window, use `niri msg action focus-monitor-left` or `niri msg action focus-monitor-right`; there is no dedicated shortcut for this yet.

Edit shortcuts in `cfg/keybinds.kdl`, keyboard input in `cfg/input.kdl`, and the main includes in `config.kdl`.
