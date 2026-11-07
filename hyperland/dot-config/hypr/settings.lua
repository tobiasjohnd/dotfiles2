local c = require("vars").colors

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 3,
        layout      = "master",
        col = {
            inactive_border = { colors = { c.base03, c.base02 }, angle = 45 },
            active_border   = { colors = { c.yellow, c.red },    angle = 45 },
        },
    },

    decoration = {
        shadow = { enabled = false },
        blur   = { enabled = false },
    },

    animations = { enabled = false },

    xwayland = { force_zero_scaling = true },

    master = {
        new_status = "master",
        mfact      = 0.50,
    },

    misc = {
        disable_hyprland_logo = true,
    },

    input = {
        kb_layout  = "gb",
        kb_variant = "extd",
        -- train away from the mouse: focus follows it between windows only,
        -- its focusing click is swallowed, and the cursor hides when idle
        follow_mouse        = 2,
        swallow_focus_click = true,
    },

    cursor = { inactive_timeout = 2 },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
