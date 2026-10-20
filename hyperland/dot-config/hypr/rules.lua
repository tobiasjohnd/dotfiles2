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
