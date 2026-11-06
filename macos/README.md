# macOS overlay package

Stow on the Mac:

    stow base macos neovim

## kanata

kanata runs on macOS through the
[Karabiner-DriverKit-VirtualHIDDevice](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice)
driver and **must run as root**. One-time setup:

1. Install the driver, **v8.0.0+** (for kanata >= v1.13.0), from its
   [releases page](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases),
   then activate it and approve the system extension:

       sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager forceActivate

   Enable it in `System Settings > General > Login Items & Extensions > Driver
   Extensions` (a reboot may be needed). If you run Karabiner-Elements, it
   manages the daemon for you and you can skip the activation step.

2. Put the kanata binary on PATH (releases page or `cargo install`), e.g.:

       sudo cp kanata-macos-arm64 /usr/local/bin/kanata

3. Grant permissions: `System Settings > Privacy & Security` — add kanata to
   **Input Monitoring** and **Accessibility**. You can pre-trigger the prompts:

       sudo /usr/local/bin/kanata --macos-request-permissions

4. List your keyboards and put the right names in `dot-config/kanata/mac.kbd`:

       sudo kanata -l

5. Install the LaunchDaemon (kanata can't run as a user LaunchAgent):

       sudo cp kanata.plist /Library/LaunchDaemons/dev.kanata.kanata.plist
       sudo chown root:wheel /Library/LaunchDaemons/dev.kanata.kanata.plist
       sudo launchctl bootstrap system /Library/LaunchDaemons/dev.kanata.kanata.plist

6. After editing the kanata config, reload with:

       sudo launchctl kickstart -k system/dev.kanata.kanata

Smoke test first with `sudo kanata -c ~/.config/kanata/mac.kbd`; logs land in
`/var/log/kanata.log`, and holding `ctrl+space+esc` exits kanata.

## Notes

- `kanata.plist` and this README are reference files: kept in the repo but
  never stowed (see the `--ignore` in `base/dot-stowrc`).
- The keymap itself is shared with Linux via `base/dot-config/kanata/keymap.kbd`;
  this package only owns the macOS `defcfg`.
