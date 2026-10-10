# Linux configs

Personal Linux configuration files. The `niri/` directory contains the Niri setup and keybinding notes. The `noctalia/` directory contains dock and external display brightness settings, KDE Connect integration, a phone avatar, and a panel customization. See [Noctalia setup](noctalia/README.md) for installation.

To activate the Noctalia override, copy `noctalia/90-linux-configs.toml` to `~/.config/noctalia/`. Noctalia reads TOML files from that directory and applies its GUI-managed `~/.local/state/noctalia/settings.toml` as a later override.
The `keyring/` directory documents the shared GNOME Keyring setup for Niri and COSMIC. It contains no keyring database or credentials.
