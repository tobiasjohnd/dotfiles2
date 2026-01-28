local awful = require("awful")

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.max,
}

return {
    term = "alacritty",
    mod = "Mod4",
    editor = os.getenv("EDITOR") or "nvim",
    tags = {
        { "term",  "a", awful.layout.layouts[1] },
        { "web",   "s", awful.layout.layouts[1] },
        { "notes", "d", awful.layout.layouts[2] },
        { "chat",  "f", awful.layout.layouts[2] },
        { "music", "g", awful.layout.layouts[2] },
    },
}
