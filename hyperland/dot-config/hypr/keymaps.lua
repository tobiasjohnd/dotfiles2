local v   = require("vars")
local mod = v.mod

-- ── Launchers ────────────────────────────────────────────────
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd(v.scripts .. "/launch-menu.sh"), { release = true })
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(v.term))
hl.bind(mod .. " + slash",  hl.dsp.exec_cmd(v.browser))


-- ── Workspaces (XMonad-style) ─────────────────────────────────
for i, key in ipairs({ "a", "s", "d", "f", "g" }) do
    hl.bind(mod .. " + " .. key,
        hl.dsp.focus({ workspace = i, on_current_monitor = true }))
    hl.bind(mod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i, follow = true }))
end

hl.bind(mod .. " + Escape", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + Tab",    hl.dsp.focus({ workspace = "e+1" }))


-- ── Window Navigation ────────────────────────────────────────
hl.bind(mod .. " + j",         hl.dsp.window.cycle_next())
hl.bind(mod .. " + k",         hl.dsp.window.cycle_next({ next = false }))
hl.bind(mod .. " + SHIFT + j", hl.dsp.window.swap({ next = true }))
hl.bind(mod .. " + SHIFT + k", hl.dsp.window.swap({ prev = true }))
hl.bind(mod .. " + m",         hl.dsp.layout("focusmaster"))
hl.bind(mod .. " + SHIFT + m", hl.dsp.layout("swapwithmaster"))


-- ── Master Layout Control ─────────────────────────────────────
hl.bind(mod .. " + h", hl.dsp.layout("mfact -0.05"), { repeating = true })
hl.bind(mod .. " + l", hl.dsp.layout("mfact +0.05"), { repeating = true })
hl.bind(mod .. " + o", hl.dsp.layout("orientationcycle left center"))


-- ── Monitor Management ────────────────────────────────────────
hl.bind(mod .. " + semicolon",         hl.dsp.focus({ monitor = "+1" }))
hl.bind(mod .. " + SHIFT + semicolon", hl.dsp.window.move({ monitor = "+1" }))


-- ── Window Management ─────────────────────────────────────────
hl.bind(mod .. " + y", hl.dsp.window.close())
hl.bind(mod .. " + u", hl.dsp.window.float())
hl.bind(mod .. " + i", hl.dsp.window.fullscreen())
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + mouse:274", hl.dsp.window.pin())


-- ── Screenshots ───────────────────────────────────────────────
-- Requires: grim, slurp, wl-copy
hl.bind("Print",           hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd([[grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | wl-copy]]))
hl.bind("SHIFT + Print",   hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))


-- ── Media & Hardware ──────────────────────────────────────────
-- Requires: wpctl (volume), brightnessctl (brightness), playerctl (media)
local media = {
    XF86AudioRaiseVolume  = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+",
    XF86AudioLowerVolume  = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
    XF86AudioMute         = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
    XF86AudioPlay         = "playerctl play-pause",
    XF86AudioNext         = "playerctl next",
    XF86AudioPrev         = "playerctl previous",
    XF86MonBrightnessUp   = "brightnessctl s +5%",
    XF86MonBrightnessDown = "brightnessctl s 5%-",
}
for key, cmd in pairs(media) do
    hl.bind(key, hl.dsp.exec_cmd(cmd), { locked = true })
end


-- ── Session Management ────────────────────────────────────────
hl.bind(mod .. " + z",         hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + x",         hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + x", hl.dsp.exit())
hl.bind(mod .. " + b",         hl.dsp.exec_cmd("echo toggle > $XDG_RUNTIME_DIR/waybar-cmd"))


-- ── Notifications ─────────────────────────────────────────────
-- Requires: dunst
hl.bind(mod .. " + n",         hl.dsp.exec_cmd("dunstctl close"))
hl.bind(mod .. " + SHIFT + n", hl.dsp.exec_cmd("dunstctl close-all"))
