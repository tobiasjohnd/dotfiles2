local gears = require("gears")
local awful = require("awful")
local keymaps = require("keymaps")
local wallpaper = require("wallpaper")
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
root.keys(keymaps.globalkeys)

wallpaper.refresh()
awful.spawn.with_shell("killall picom ; picom --backend xrender --no-fading-openclose")
