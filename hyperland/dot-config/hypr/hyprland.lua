-- Hyprland Lua config (faithful port of hyprland.conf)
-- https://wiki.hypr.land/Configuring/

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

---------------------
---- VARIABLES ------
---------------------

local mod         = "SUPER"
local scripts     = "~/.config/hypr/scripts"
local term        = "alacritty"
local browser     = "helium"
local fileManager = "Dolphin"
local launcher    = "~/.config/hypr/scripts/launch-menu.sh"

-- Solarized Colour Palette
local sol = {
    base03  = "0xff002b36",
    base02  = "0xff073642",
    base01  = "0xff586e75",
    base00  = "0xff657b83",
    base0   = "0xff839496",
    base1   = "0xff93a1a1",
    base2   = "0xffeee8d5",
    base3   = "0xfffdf6e3",
    yellow  = "0xffb58900",
    orange  = "0xffcb4b16",
    red     = "0xffdc322f",
    magenta = "0xffd33682",
    violet  = "0xff6c71c4",
    blue    = "0xff268bd2",
    cyan    = "0xff2aa198",
    green   = "0xff859900",
}

-------------------
---- AUTOSTART ----
-------------------

-- Runs on every config load (was `exec`)
hl.exec_cmd("killall waybar ; waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/style.css")

-- Runs once at startup (was `exec-once`)
hl.on("hyprland.start", function()
    hl.exec_cmd(scripts .. "/waybar-controller.sh")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 0,
        gaps_out = 0,

        border_size = 3,

        col = {
            inactive_border = { colors = { sol.base03, sol.base02 }, angle = 45 },
            active_border   = { colors = { sol.yellow, sol.red },    angle = 45 },
        },

        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "master",
    },

    decoration = {
        rounding = 0,
        shadow = {
            enabled = false,
        },
        blur = {
            enabled = false,
        },
    },

    xwayland = {
        force_zero_scaling = true,
    },

    animations = {
        enabled = false,
    },
})

-- "Smart gaps" / "No gaps when only" (disabled)
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },

    master = {
        new_status  = "master",
        mfact       = 0.50,
        orientation = "left",
    },

    misc = {
        force_default_wallpaper = -1,   -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "gb",
        kb_variant = "extd",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------

-- ── Launchers ────────────────────────────────────────────────
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd(launcher), { release = true })
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(term))

-- Web browser
hl.bind(mod .. " + slash", hl.dsp.exec_cmd(browser))


-- ── Workspaces (XMonad-style) ─────────────────────────────────
local ws_keys = { "a", "s", "d", "f", "g" }
for i, key in ipairs(ws_keys) do
    hl.bind(mod .. " + " .. key,
        hl.dsp.focus({ workspace = i, on_current_monitor = true }))
    -- Move focused window to workspace
    hl.bind(mod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i, follow = true }))
end

-- Workspace history
hl.bind(mod .. " + Escape", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + Tab",    hl.dsp.focus({ workspace = "e+1" }))

-- ── Special Workspaces (Scratchpads) ─────────────────────────
hl.bind(mod .. " + q", hl.dsp.exec_cmd(scripts .. "/scratchpad.sh files    org.kde.dolphin"))
hl.bind(mod .. " + w", hl.dsp.exec_cmd(scripts .. "/scratchpad.sh discord  com.discordapp.Discord"))
hl.bind(mod .. " + e", hl.dsp.exec_cmd(scripts .. "/scratchpad.sh obsidian md.obsidian.Obsidian"))
hl.bind(mod .. " + r", hl.dsp.exec_cmd(scripts .. "/scratchpad.sh zotero   zotero"))
hl.bind(mod .. " + t", hl.dsp.exec_cmd(scripts .. "/scratchpad.sh spotify  com.spotify.Client"))

-- Window rules — assign each app to its scratchpad on launch
hl.window_rule({ match = { class = "^(" .. fileManager .. ")$" }, workspace = "special:files silent" })
hl.window_rule({ match = { class = "^(discord)$" },               workspace = "special:discord silent" })
hl.window_rule({ match = { class = "^(obsidian)$" },              workspace = "special:obsidian silent" })
hl.window_rule({ match = { class = "^(Zotero)$" },                workspace = "special:zotero silent" })
hl.window_rule({ match = { class = "^(Spotify)$" },               workspace = "special:spotify silent" })

-- Scratchpad sizing (gap around the overlay window)
hl.workspace_rule({ workspace = "special:files",    gaps_out = 50 })
hl.workspace_rule({ workspace = "special:discord",  gaps_out = 50 })
hl.workspace_rule({ workspace = "special:obsidian", gaps_out = 50 })
hl.workspace_rule({ workspace = "special:zotero",   gaps_out = 50 })
hl.workspace_rule({ workspace = "special:spotify",  gaps_out = 50 })


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
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + mouse:274", hl.dsp.window.pin())
hl.bind(mod .. " + i", hl.dsp.window.fullscreen())


-- ── Screenshots ───────────────────────────────────────────────
-- Requires: grim, slurp, wl-copy
hl.bind("Print",           hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd([[grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | wl-copy]]))
hl.bind("SHIFT + Print",   hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))


-- ── Media & Hardware ──────────────────────────────────────────
-- Requires: wpctl (volume), brightnessctl (brightness), playerctl (media)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                             { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                   { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                               { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s +5%"),                              { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"),                              { locked = true })


-- ── Session Management ────────────────────────────────────────
hl.bind(mod .. " + z",         hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + x",         hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + x", hl.dsp.exit())
hl.bind(mod .. " + b",         hl.dsp.exec_cmd("echo toggle > $XDG_RUNTIME_DIR/waybar-cmd"))


-- ── Notifications ─────────────────────────────────────────────
-- Requires: dunst
hl.bind(mod .. " + n",         hl.dsp.exec_cmd("dunstctl close"))
hl.bind(mod .. " + SHIFT + n", hl.dsp.exec_cmd("dunstctl close-all"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name  = "flameshot",
    match = { class = "flameshot" },

    float        = true,
    move         = { 0, 0 },
    pin          = true,
    stay_focused = true,
    border_size  = 0,
    no_anim      = true,
    monitor      = "eDP-1",
})
