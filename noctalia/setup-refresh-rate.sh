#!/usr/bin/env bash
set -euo pipefail
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/refresh-rate
plugin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/noctalia/plugins/refresh-rate"
mkdir -p "$plugin_dir"
cp "$source_dir/plugin.toml" "$source_dir/widget.luau" "$source_dir/panel.luau" "$source_dir/display-control.py" "$plugin_dir/"
noctalia msg config-reload
noctalia msg plugins enable local/refresh-rate
python3 - <<'PY'
import json
import os
from pathlib import Path
import subprocess
import tomllib

config = tomllib.loads(subprocess.check_output(["noctalia", "config", "export", "full"], text=True))
bars = config["bar"]
bar_name = bars.get("order", ["default"])[0]
end = list(bars[bar_name].get("end", []))
if "refresh-rate" not in end:
    position = end.index("brightness") + 1 if "brightness" in end else len(end)
    end.insert(position, "refresh-rate")
directory = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "noctalia"
directory.mkdir(parents=True, exist_ok=True)
(directory / "96-refresh-rate.toml").write_text(
    "# Local refresh-rate widget; does not replace Control Center shortcuts.\n"
    + '[widget.refresh-rate]\ntype = "local/refresh-rate:rate"\n\n'
    + f'[bar.{json.dumps(bar_name)}]\nend = {json.dumps(end)}\n'
)
PY
noctalia config validate
noctalia msg config-reload
