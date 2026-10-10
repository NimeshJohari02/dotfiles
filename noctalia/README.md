# Noctalia setup

Copy `90-linux-configs.toml` into `~/.config/noctalia/`. It configures the dock,
external display brightness, polkit agent, and KDE Connect tile first in the
Control Center shortcut grid. Weather is disabled. Noctalia 5.2.1 shows six
shortcuts, so the final power-profile entry is hidden; use the Power sidebar.
The large date card remains because this version cannot replace it through config.

Install `kdeconnect`, and enable the integration while Noctalia is running:

```sh
noctalia msg plugins enable icefish/phone-connect
kdeconnect-cli --list-devices
```

Once installation finishes, set the avatar and hide the cellular indicator:

```sh
bash noctalia/setup-phone-connect.sh DEVICE_ID
```

Replace `DEVICE_ID` with your paired phone's ID. The script backs up the plugin
and its per-device state, copies the Snorlax avatar into Noctalia's assets, and
applies a patch tested against Phone Connect 0.2.0. It can be rerun safely.
Plugin updates can overwrite the patch; rerun the script after updating and
review it if the new version no longer matches. Pairing keys and private phone
state are intentionally not stored in this repository.

With the `niri/` configuration installed, `kdeconnectd` starts at login without
opening the KDE Connect UI. Press `Super + S` and click the phone tile for
battery status, media, clipboard, sharing, and other phone controls.

Validate with `noctalia config validate noctalia` and `niri validate -c niri/config.kdl`.

For automatic suspend, copy `idle-battery-suspend.sh` to
`~/.local/bin/noctalia-idle-battery-suspend` and `95-idle-power.toml` to
`~/.config/noctalia/`, then run `noctalia msg config-reload`.
Monitors turn off and the laptop suspends after 15 idle minutes on battery or
30 idle minutes on AC, plus a two-second cancellable fade. This config uses
ordinary suspend; it does not enable hibernation or change CachyOS's system
sleep configuration. Activity restores monitor power on resume. Caffeine and
application idle inhibitors can keep the session awake.
