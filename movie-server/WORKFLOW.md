# Movie on my TV

User-approved shortcut: "Movie on my TV" means start the existing ReadyMedia
server so the Samsung TV can play local movie files directly over Wi-Fi.
"Done watching" means stop sharing and restore any session-specific settings.

## Existing setup

- Samsung Q60D 65-inch TV, advertised as `65" QLED`; last known IP <tv-ip>.
  Discover/verify its current address rather than assuming this never changes.
- Server name shown on TV: **Nimesh Movies**.
- Movies: `/home/nimesh/Videos/Movies`.
- User service: `readymedia.service`.
- Config: `~/.config/readymedia/minidlna.conf`.
- Installed server: `~/.local/share/readymedia/usr/bin/minidlnad`; private library
  directory `~/.local/share/readymedia/usr/lib` is configured in the service.
- Setup sources: `~/Dev/linux-configs/movie-server/` (saved on GitHub main/master).
- Laptop last used wlan0 on <laptop-ip>/24. Verify current interface/address.

## Start

1. Check Wi-Fi/network and the TV's current address (for example with
   `avahi-browse -art --terminate`). Check the configured interface still matches.
2. Inspect `/etc/ufw/user.rules` for the TV's TCP 8200 access. The previous movie
   session's TV-specific exception was removed at cleanup. Re-add only the
   necessary TV-specific rule if absent:
   `sudo ufw allow in on wlan0 proto tcp from TV_IP to any port 8200 comment 'Samsung TV ReadyMedia'`.
   Substitute the verified interface and address. Existing UFW before.rules
   permits multicast SSDP discovery on 239.255.255.250 UDP 1900. Inspect before
   adding extra discovery rules. Record any new rule for exact cleanup later.
   If sudo needs a password, prepare the concrete command in an Alacritty
   terminal for the user; never request their password in chat.
3. `systemctl --user start readymedia` (do not reinstall or restart an already
   working stream). This service enables Noctalia Caffeine and inhibits
   idle/sleep; its stop hook disables Caffeine.
4. Verify service active, `http://LAPTOP_IP:8200/rootDesc.xml` responds, and the
   movie catalog is indexed. Playback on the TV still requires the remote.
5. On TV: Home → Connected Devices / Sources → Nimesh Movies → movie.

Use direct file streaming. Do not start HDMI mirroring or laptop playback.
Preserve the user's chosen refresh rate, brightness, audio output, and power
profile unless they explicitly request changes. The laptop normally uses
1920×1080 at 144.003 Hz. The user has a separate local Noctalia top-bar
refresh-rate plugin for manual changes; keep it installed.

## English subtitles

Prefer English. If requested, find an SRT matching the actual release/runtime,
validate that it is subtitle text, and place it beside the video with exactly
the same basename (`Movie.mkv` and `Movie.srt`), encoded as UTF-8. ReadyMedia
indexes sidecars live; no server restart is needed. Check the CAPTIONS table in
`~/.local/state/readymedia/files.db` and Samsung `CaptionInfo.sec` response
header / `/Captions/DETAIL_ID.srt` endpoint. Tell the user to reopen the movie
and enable subtitles if the TV cached its previous state. Do not promise
perfect sync without checking; burned-in foreign text cannot be switched off.

## Finish

1. `systemctl --user stop readymedia` and `noctalia msg caffeine-disable`.
2. Verify the movie server and any movie-specific sleep inhibitors are gone.
3. Remove only TV firewall rules created for this session. For the example
   above: `sudo ufw --force delete allow in on wlan0 proto tcp from TV_IP to any port 8200 comment 'Samsung TV ReadyMedia'`.
   Use a terminal password prompt when needed, then verify the rule disappeared.
4. Restore only settings changed for this session from a fresh pre-session
   snapshot. Do not reuse the old first-movie snapshot automatically: it is
   historical and may override newer user preferences.
5. Leave the server installed but stopped and disabled at login, retain the
   refresh-rate plugin, and retain movie/subtitle files.

Last completed cleanup (2026-10-20): server stopped, Caffeine off, TV firewall
exception removed, laptop speakers selected, brightness 12811/65535,
Performance power profile, and laptop refresh rate 144.003 Hz. These are
historical verified values, not a reason to override future preferences.
