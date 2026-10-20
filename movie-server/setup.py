#!/usr/bin/env python3
"""Configure a per-user ReadyMedia server without enabling it at login."""
import argparse
import ipaddress
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


def unit_quote(value):
    # systemd expands percent specifiers even inside quoted arguments.
    return json.dumps(str(value).replace("%", "%%"), ensure_ascii=False)


def save(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_text() != content:
        backup = path.with_name(path.name + ".bak-" + str(time.time_ns()))
        shutil.copy2(path, backup)
    path.write_text(content)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--media-dir", type=Path, default=Path.home() / "Videos/Movies")
    parser.add_argument("--interface", help="Wi-Fi/LAN interface; defaults to the IPv4 route interface")
    parser.add_argument("--name", default="Nimesh Movies", help="Name displayed on the TV")
    parser.add_argument("--tv-ip", type=ipaddress.IPv4Address, help="TV address, required with --allow-tv")
    parser.add_argument("--allow-tv", action="store_true", help="Use sudo to add TV-only UFW rules")
    parser.add_argument("--install-deps", action="store_true", help="Install minidlna with pacman (Arch/CachyOS)")
    parser.add_argument("--no-start", action="store_true", help="Only write files; do not reload, start, or restart services")
    args = parser.parse_args()
    if args.allow_tv and not args.tv_ip:
        parser.error("--allow-tv requires --tv-ip")
    if args.no_start and (args.allow_tv or args.install_deps):
        parser.error("--no-start cannot be combined with privileged setup options")
    if args.install_deps:
        if not shutil.which("pacman"):
            parser.error("Install ReadyMedia using your distribution's package manager first.")
        subprocess.run(["sudo", "pacman", "-S", "--needed", "minidlna"], check=True)

    binary = shutil.which("minidlnad")
    local_binary = Path.home() / ".local/share/readymedia/usr/bin/minidlnad"
    if not binary and local_binary.is_file():
        binary = str(local_binary)
    if not binary:
        parser.error("minidlnad is missing. On Arch/CachyOS, rerun with --install-deps.")
    for command in ("systemd-inhibit", "systemctl"):
        if not shutil.which(command):
            parser.error(f"Required command missing: {command}")

    interface = args.interface
    if not interface:
        route = json.loads(subprocess.check_output(["ip", "-j", "route", "get", "239.255.255.250"], text=True))
        interface = route[0]["dev"]
    if not re.fullmatch(r"[A-Za-z0-9_.:-]+", interface):
        parser.error("Invalid interface name")
    if not Path("/sys/class/net", interface).exists():
        parser.error(f"Network interface does not exist: {interface}")
    if not args.name.strip() or any(c in args.name for c in "\r\n\0"):
        parser.error("The server name must be one nonempty line")
    media = args.media_dir.expanduser().resolve()
    if any(c in str(media) for c in "\r\n\0"):
        parser.error("Media directory must not contain newlines")
    media.mkdir(parents=True, exist_ok=True)
    config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    state_home = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state"))
    config = config_home / "readymedia/minidlna.conf"
    state = state_home / "readymedia"
    state.mkdir(parents=True, exist_ok=True)
    save(config, f"""port=8200
network_interface={interface}
friendly_name={args.name}
media_dir=V,{media}
db_dir={state}
log_dir={state}
inotify=yes
enable_tivo=no
strict_dlna=no
enable_subtitles=yes
notify_interval=60
root_container=B
max_connections=10
log_level=general,scanner,metadata,http,ssdp=info
""")
    unit = """[Unit]
Description=ReadyMedia movie sharing on home Wi-Fi
After=network.target

[Service]
Type=simple
Environment=LC_ALL=C.UTF-8
"""
    if Path(binary) == local_binary:
        unit += "Environment=" + unit_quote("LD_LIBRARY_PATH=" + str(local_binary.parent.parent / "lib")) + "\n"
    noctalia = shutil.which("noctalia")
    if noctalia:
        unit += f"ExecStartPre=-{unit_quote(noctalia)} msg caffeine-enable\n"
        unit += f"ExecStopPost=-{unit_quote(noctalia)} msg caffeine-disable\n"
    command = [shutil.which("systemd-inhibit"), "--what=idle:sleep", "--why=Streaming movies to TV",
               binary, "-S", "-f", str(config), "-P", str(state / "minidlna.pid")]
    unit += "ExecStart=" + " ".join(map(unit_quote, command)) + "\n"
    unit += "Restart=on-failure\nRestartSec=5\nNice=10\n\n[Install]\nWantedBy=default.target\n"
    unit_path = config_home / "systemd/user/readymedia.service"
    save(unit_path, unit)
    workflow = Path(__file__).with_name("WORKFLOW.md")
    if workflow.is_file():
        data_home = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
        save(data_home / "readymedia/WORKFLOW.md", workflow.read_text())
    print(f"Configured: {config}\nService: {unit_path}\nSharing: {media}")
    if args.no_start:
        return
    if args.allow_tv:
        ufw = shutil.which("ufw")
        if not ufw:
            parser.error("UFW is not installed; configure your firewall's TCP 8200 / UDP 1900 rules manually.")
        for protocol, port in (("tcp", "8200"), ("udp", "1900")):
            subprocess.run(["sudo", ufw, "allow", "in", "on", interface, "proto", protocol,
                            "from", str(args.tv_ip), "to", "any", "port", port,
                            "comment", "TV ReadyMedia"], check=True)
    subprocess.run(["systemctl", "--user", "daemon-reload"], check=True)
    # 'start' is intentional: rerunning setup must not interrupt an existing movie.
    subprocess.run(["systemctl", "--user", "start", "readymedia.service"], check=True)
    subprocess.run(["systemctl", "--user", "is-active", "--quiet", "readymedia.service"], check=True)
    print(f"Server running. On the TV, open Connected Devices / Sources > {args.name}.")
    print("Already running? New configuration takes effect after you finish watching and restart the service.")
    print("Stop when finished: systemctl --user stop readymedia")


if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.SubprocessError, ValueError) as error:
        print(f"Setup failed: {error}", file=sys.stderr)
        sys.exit(1)
