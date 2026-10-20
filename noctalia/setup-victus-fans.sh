#!/usr/bin/env bash
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/victus-fans
plugin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/noctalia/plugins/victus-fans"
mkdir -p "$plugin_dir"
cp "$source_dir/plugin.toml" "$source_dir/tile.luau" "$source_dir/fan-control.py" "$plugin_dir/"
noctalia msg config-reload
noctalia msg plugins enable local/victus-fans
