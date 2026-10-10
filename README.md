# Linux configs

Personal Linux configuration files. The `niri/` directory contains the Niri setup and keybinding notes. The `noctalia/` directory contains a minimal Noctalia dock and external display brightness override.

To activate the Noctalia override, copy `noctalia/90-linux-configs.toml` to `~/.config/noctalia/`. Noctalia reads TOML files from that directory and applies its GUI-managed `~/.local/state/noctalia/settings.toml` as a later override.
