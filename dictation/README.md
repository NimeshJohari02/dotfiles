# Local voice dictation

Press **Super+V** to record, then press it again to transcribe English and paste
into the focused text box. Keep that box focused until the text arrives.
Recording stops after 120 seconds. Notifications show recording/transcription;
the shortcut does not send Enter. **Super+Shift+V** opens clipboard history;
floating/tiling focus is on **Super+Ctrl+Shift+V**.

Voxtype sends audio to Phonon-2 on `127.0.0.1:8010`. The speech server runs
locally on the CPU with four threads. Paste uses `wtype` to send Shift+Insert
and replaces the clipboard with the transcript; paste manually if an app does
not accept the shortcut. The tracked Alacritty TOML binds Shift+Insert to
`Paste`, while middle-click continues to use `PasteSelection`.

## Restore dependencies

The working installation uses Voxtype 1.1.1 (Linux x86_64 AVX2),
`fermion-research==0.2.11`, Python 3.14, and wtype built from commit
`d71be3a7b3f93b534a2823fd68cabd7ac2a02359`. Install Python/pip, PipeWire,
`wl-clipboard`, `wtype`, and the libraries needed by Voxtype on the target
machine. Its existing `graphical-session.target` must start with Niri.

Download `voxtype-1.1.1-linux-x86_64-avx2` from the
[Voxtype v1.1.1 release](https://github.com/peteonrails/voxtype/releases/tag/v1.1.1).
Its SHA256 is
`3462262980e5a75391ffdeb7d3b63f9f638d6261df042f04f9119dfb7aab7770`.
This build requires an AVX2-capable CPU. Place it under
`~/.local/share/phonon-dictation/`, make it executable, and symlink it as
`~/.local/bin/voxtype`. Ensure `~/.local/bin/wtype` or `/usr/bin/wtype` exists.

Create the isolated speech runtime and download the model once while online:

```sh
python3 -m venv ~/.local/share/phonon-dictation/venv
~/.local/share/phonon-dictation/venv/bin/python -m pip install torch==2.14.1+cpu --index-url https://download.pytorch.org/whl/cpu
~/.local/share/phonon-dictation/venv/bin/python -m pip install 'fermion-research==0.2.11'
~/.local/share/phonon-dictation/venv/bin/fermion transcribe phonon-2 --download-only
```

`requirements-installed.txt` records the installed Python versions for reference.
The service sets `HF_HUB_OFFLINE=1`, so populate the model cache before enabling
it. Model weights, the virtual environment, executables, audio, and transcripts
remain outside this repository.

## Restore configuration

From the repository root:

```sh
mkdir -p ~/.config/voxtype ~/.config/systemd/user
cp dictation/voxtype.toml ~/.config/voxtype/config.toml
cp dictation/systemd/*.service ~/.config/systemd/user/
```

Copy `niri/cfg/keybinds.kdl` into `~/.config/niri/cfg/`, or merge its dictation
and clipboard bindings into your existing config. Copy
`alacritty/alacritty.toml` into `~/.config/alacritty/`, or merge its Shift+Insert
binding into your existing `[keyboard].bindings` array. Preserve any other
local customizations when restoring.

Then validate and enable:

```sh
niri validate
systemctl --user daemon-reload
systemctl --user enable --now phonon-server.service voxtype.service
voxtype status
```

## Troubleshooting

```sh
voxtype record cancel
systemctl --user restart voxtype
systemctl --user status phonon-server voxtype
journalctl --user -u phonon-server -u voxtype -n 50
```

To disable, run `systemctl --user disable --now voxtype phonon-server` and remove
the dictation binding from Niri.

Sources: [Phonon-2](https://huggingface.co/FermionResearch/Phonon-2),
[Phonon runtime](https://github.com/fermionresearch/phonon),
[Voxtype](https://github.com/peteonrails/voxtype), [wtype](https://github.com/atx/wtype).
