# Shared Secret Service keyring (Niri and COSMIC)

This setup uses GNOME Keyring as the single `org.freedesktop.secrets` provider for the same Unix user. Both desktop sessions use the user's D-Bus session and the same keyring files under `~/.local/share/keyrings/`; do not copy keyring files into this repository.

## VS Code

In `~/.config/Code/argv.json`, set:

```json
{
  "password-store": "gnome-libsecret"
}
```

Restart VS Code after changing this. It will use the Secret Service instead of Electron's weaker fallback storage.

## Unlock on greetd login

Add the following to `/etc/pam.d/greetd`, after the existing `auth include system-local-login` and `session include system-local-login` lines respectively:

```pam
 auth       optional     pam_gnome_keyring.so
 session    optional     pam_gnome_keyring.so auto_start
```

The PAM module unlocks the keyring named `login` when its password matches the account login password. The user session must have only one `org.freedesktop.secrets` provider active. GNOME Keyring's systemd user socket can start it on demand.

The current machine has GNOME Keyring installed, the socket enabled, and COSMIC's separate `oo7` provider absent, so both sessions resolve to GNOME Keyring. Its PAM hooks are configured in `/etc/pam.d/greetd`.

The existing keyring collection on that machine is currently named `Default keyring` and has only the `default` alias. PAM auto-unlock applies to the `login` keyring; use a keyring manager to move or rename the existing collection to `login` and set its password to the account login password if automatic unlock is needed. Do not store keyring passwords or secret contents in this repository.
