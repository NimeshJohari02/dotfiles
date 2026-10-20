# Movie sharing with ReadyMedia

Streams original video files to a DLNA-capable TV over the home network. The TV
decodes the video; the laptop serves the file without transcoding or mirroring.
Only the selected movie directory is indexed. No movie files, subtitles,
downloaded packages, or generated databases are stored in this repository.

On Arch/CachyOS, install and start with:

```bash
bash movie-server/setup.sh --install-deps --interface wlan0
```

If ReadyMedia is already installed, omit `--install-deps`. The script also
recognizes the existing user-local installation at
`~/.local/share/readymedia/usr/bin/minidlnad`. On other distributions, install
ReadyMedia with the appropriate package manager first. Python 3, systemd user
services, and `ip` are required. Run setup as your regular user.

The default directory is `~/Videos/Movies`, and the TV sees **Nimesh Movies**.
Override with `--media-dir /path/to/movies` and `--name "Movies"`. The network
interface is detected automatically when `--interface` is omitted.

For UFW, allow just your TV's address (replace the example with its current IP):

```bash
bash movie-server/setup.sh --interface wlan0 --tv-ip <tv-ip> --allow-tv
```

This uses sudo for TCP 8200 (catalog/media/subtitles) and UDP 1900 (discovery)
rules. It does not disable the firewall or forward router ports. If the TV's
address changes, update the rules. The server has no authentication: other
devices permitted by your existing firewall rules may also access it.

On the TV, open **Home → Connected Devices / Sources → Nimesh Movies**, then
select the movie. Keep both devices on the same network. Guest Wi-Fi/client
isolation may prevent discovery.

For subtitles, place a UTF-8 SRT beside the movie with the exact same basename:

```text
Example Movie.mkv
Example Movie.srt
```

ReadyMedia detects the SRT automatically. Reopen the movie on the TV and enable
subtitles in its playback options. Subtitle timing and codec support depend on
the file and TV; ReadyMedia does not translate subtitles or transcode video.

The setup writes `~/.config/readymedia/minidlna.conf` and a
`~/.config/systemd/user/readymedia.service` user unit, with the index/logs in
`~/.local/state/readymedia`. Existing changed files are backed up before writing.
It honors `XDG_CONFIG_HOME` and `XDG_STATE_HOME`. `--no-start` writes these files
without touching services or the firewall, for reviewing a generated setup.

```bash
systemctl --user start readymedia       # share movies
systemctl --user stop readymedia        # stop sharing, restore normal idle sleep
systemctl --user status readymedia
journalctl --user -u readymedia -n 30
```

While the service is running, it inhibits sleep and idle suspend; if Noctalia is
installed it also enables Caffeine and disables it when the service stops.
Stop the service when finished. Startup at login is intentionally disabled.
Rerunning setup does not interrupt a currently playing movie; apply changed
settings later with `systemctl --user restart readymedia`.
