awful = require("awful")

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.fair,
    awful.layout.suit.max,
}

return {
    terminal = "alacritty",
    editor = os.getenv("EDITOR") or "nvim",
    wallpaper = "feh --bg-fill $(ls -d $HOME/Wallpaper/* | shuf | head -1)",
    tags = {
        { "main", "a", awful.layout.layouts[1] },
        { "web", "s", awful.layout.layouts[1] },
        { "notes", "d", awful.layout.layouts[2] },
        { "chat", "f", awful.layout.layouts[3] },
        { "media", "g", awful.layout.layouts[3] },
    },
}

