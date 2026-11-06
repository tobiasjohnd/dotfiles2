# Linux overlay package

Stow on Linux machines:

    stow base linux neovim

## Secret storage

`base/dot-zshrc` loads `GREENPT_API_KEY` from the OS keyring in its
platform guards. On Linux the query goes through `secret-tool`, which
needs a one-time setup per machine:

1. Install the tools (Arch):

       pacman -S libsecret gnome-keyring

2. Make sure the keyring is running and unlocked in your session — for a
   standalone WM like Hyprland or awesome, start it via your autostart
   (or PAM):

       gnome-keyring-daemon --start --components=secrets

3. Store the secret (prompts for the value):

       secret-tool store --label=greenpt service greenpt

Until the entry exists the export is just an empty string; the zshrc
query uses `timeout 2` so a locked keyring cannot hang the shell.

## Notes

- `dnf.conf` is a reference file — its real home is `/etc/dnf/dnf.conf`.
- This README is never stowed (see the `--ignore` in `base/dot-stowrc`).
