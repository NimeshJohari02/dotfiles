#!/usr/bin/env python3
"""Small client for the installed Victus backend's length-prefixed protocol."""
import socket
import struct
import sys


def receive(sock, size):
    data = bytearray()
    while len(data) < size:
        chunk = sock.recv(size - len(data))
        if not chunk:
            raise ConnectionError("Victus backend closed the connection")
        data.extend(chunk)
    return bytes(data)


def query(command):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.settimeout(2)
        sock.connect("/run/victus-control/victus_backend.sock")
        payload = command.encode()
        sock.sendall(struct.pack("<I", len(payload)) + payload)
        size = struct.unpack("<I", receive(sock, 4))[0]
        if not 0 < size <= 4096:
            raise ValueError("Invalid Victus backend response length")
        return receive(sock, size).decode().strip()


def main():
    action = sys.argv[1:]
    if action not in (["status"], ["toggle"]):
        raise ValueError("Usage: fan-control.py status|toggle")
    mode = query("GET_FAN_MODE")
    if mode not in ("AUTO", "MAX", "MANUAL", "BETTER_AUTO"):
        raise ValueError(mode)
    if action == ["toggle"]:
        target = "AUTO" if mode == "MAX" else "MAX"
        reply = query("SET_FAN_MODE " + target)
        if reply != "OK":
            raise ValueError(reply)
        mode = query("GET_FAN_MODE")
        if mode != target:
            raise ValueError("Victus did not confirm " + target)
    print(mode)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, ConnectionError, UnicodeError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)
