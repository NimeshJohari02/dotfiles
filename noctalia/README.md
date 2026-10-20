# Noctalia refresh-rate plugin

Run `bash noctalia/setup-refresh-rate.sh` in a running Noctalia session on Niri.
Python 3.11 or later and Noctalia plugin API 24 or later are required.

The local `local/refresh-rate` plugin adds a widget showing the current refresh
rate beside brightness in the top bar. Click it to choose an advertised refresh
rate at each display’s current resolution. It preserves existing Control Center
shortcuts and the packaged Noctalia binary. Mode changes apply to the current
session; the Niri configuration is not rewritten.

The bar layout override is in `~/.config/noctalia/96-refresh-rate.toml`; edit that
file to rearrange its widgets. To remove the control, delete that file, run
`noctalia msg plugins disable local/refresh-rate`, then `noctalia msg config-reload`.

Validate with:

```bash
noctalia plugins lint noctalia/refresh-rate
python3 -m unittest discover -s noctalia/refresh-rate -p 'test_*.py'
```
