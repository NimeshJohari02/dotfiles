#!/usr/bin/env python3
"""Query Niri and apply only advertised modes at the current resolution."""
import json
import subprocess
import sys


def query():
    result = subprocess.run(
        ["niri", "msg", "-j", "outputs"], check=True,
        capture_output=True, text=True, timeout=4,
    )
    return json.loads(result.stdout)


def active_modes(outputs):
    displays = []
    for output in outputs.values():
        index = output.get("current_mode")
        modes = output.get("modes", [])
        if index is None or not 0 <= index < len(modes):
            continue
        current = modes[index]
        rates = sorted({
            m["refresh_rate"] for m in modes
            if (m["width"], m["height"]) == (current["width"], current["height"])
        })
        displays.append({
            "name": output["name"],
            "label": " ".join(filter(None, [output.get("make"), output.get("model")])),
            "width": current["width"], "height": current["height"],
            "rate": current["refresh_rate"], "rates": rates,
        })
    return sorted(displays, key=lambda d: (not d["name"].startswith("eDP"), d["name"]))


def set_rate(name, rate):
    displays = active_modes(query())
    display = next((d for d in displays if d["name"] == name), None)
    if display is None:
        raise ValueError("Display is disconnected or disabled. Reopen this panel.")
    if rate not in display["rates"]:
        raise ValueError("That refresh rate is unavailable at the current resolution.")
    if rate != display["rate"]:
        mode = f'{display["width"]}x{display["height"]}@{rate / 1000:.3f}'
        subprocess.run(
            ["niri", "msg", "output", name, "mode", mode], check=True,
            capture_output=True, text=True, timeout=5,
        )
    actual = active_modes(query())
    updated = next((d for d in actual if d["name"] == name), None)
    if updated is None or updated["rate"] != rate:
        raise RuntimeError("The display did not confirm the requested refresh rate.")
    return actual


def main(args):
    try:
        if args == ["status"]:
            displays = active_modes(query())
        elif len(args) == 3 and args[0] == "set":
            displays = set_rate(args[1], int(args[2]))
        else:
            raise ValueError("Usage: display-control.py status | set OUTPUT RATE_MILLIHZ")
        print(json.dumps({"displays": displays}))
        return 0
    except (ValueError, RuntimeError, OSError, subprocess.SubprocessError) as exc:
        message = getattr(exc, "stderr", None) or str(exc)
        print(json.dumps({"error": message.strip()}))
        return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
