#!/usr/bin/env bash
set -euo pipefail

# Noctalia calls this after 15 idle minutes. Its 30-minute action covers AC.
power_supply_dir="${NOCTALIA_POWER_SUPPLY_DIR:-/sys/class/power_supply}"
on_ac=false
has_battery=false
for supply in "$power_supply_dir"/*; do
    [[ -r "$supply/type" ]] || continue
    supply_type=$(cat "$supply/type")
    if [[ "$supply_type" == Battery ]]; then
        has_battery=true
    elif [[ -r "$supply/online" ]] && [[ $(cat "$supply/online") == 1 ]]; then
        on_ac=true
    fi
done
if [[ ${1:-} == --check ]]; then
    if $on_ac; then echo "AC: suspend at 30 minutes";
    elif $has_battery; then echo "Battery: suspend at 15 minutes";
    else echo "No battery: suspend at 30 minutes"; fi
    exit 0
fi
if $has_battery && ! $on_ac; then
    niri msg action power-off-monitors
    noctalia msg session suspend
fi
