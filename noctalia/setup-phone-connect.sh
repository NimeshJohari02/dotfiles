#!/usr/bin/env bash
set -euo pipefail

# Run after enabling Phone Connect, with the paired device ID from kdeconnect-cli.
if [[ $# != 1 ]]; then
    echo "Usage: $0 DEVICE_ID (see kdeconnect-cli --list-devices)" >&2
    exit 1
fi
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/noctalia"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/noctalia"
plugin_dir="$state_dir/plugins/materialized/community/phone-connect"
patch_file="$repo_dir/patches/phone-connect-hide-cellular.patch"

if [[ ! -f "$plugin_dir/panel.luau" ]]; then
    echo "Enable icefish/phone-connect first: noctalia msg plugins enable icefish/phone-connect" >&2
    echo "Wait for installation to finish, then run this script again." >&2
    exit 1
fi

# Back up before changing the installed plugin or avatar.
backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/linux-configs-backups/phone-connect-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$backup_dir" "$config_dir/assets"
cp -a "$plugin_dir" "$backup_dir/plugin"
if [[ -d "$state_dir/plugins/data/icefish/phone-connect" ]]; then
    cp -a "$state_dir/plugins/data/icefish/phone-connect" "$backup_dir/data"
fi
if [[ -f "$config_dir/assets/phone-snorlax.jpg" ]]; then
    cp -a "$config_dir/assets/phone-snorlax.jpg" "$backup_dir/phone-snorlax.jpg"
fi

if patch --dry-run --forward --silent -d "$plugin_dir" -p0 < "$patch_file"; then
    patch --forward -d "$plugin_dir" -p0 < "$patch_file"
elif patch --dry-run --reverse --silent -d "$plugin_dir" -p0 < "$patch_file"; then
    echo "Cellular indicator is already hidden."
else
    echo "Plugin version differs; review the patch before applying. Backup: $backup_dir" >&2
    exit 1
fi

cp "$repo_dir/assets/phone-snorlax.jpg" "$config_dir/assets/phone-snorlax.jpg"
payload=$(python - "$1" "$config_dir/assets/phone-snorlax.jpg" <<'PY'
import json, sys
print(json.dumps({"op": "set_image", "device": sys.argv[1], "path": sys.argv[2]}))
PY
)
noctalia msg config-reload
noctalia msg plugin icefish/phone-connect:kde all cmd "$payload"
echo "Phone avatar saved; cellular indicator hidden. Backup: $backup_dir"
