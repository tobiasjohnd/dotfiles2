local awful = require("awful")

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.fair,
    awful.layout.suit.max,
}

return {
    term = "alacritty",
    mod = "Mod4",
    editor = os.getenv("EDITOR") or "nvim",
    wallpaper_path = os.getenv("HOME") .. "/wallpaper.jpg",
    tags = {
        { "main",  "a", awful.layout.layouts[1] },
        { "web",   "s", awful.layout.layouts[1] },
        { "term",  "d", awful.layout.layouts[2] },
        { "notes", "f", awful.layout.layouts[3] },
        { "misc",  "g", awful.layout.layouts[3] },
    },
}
