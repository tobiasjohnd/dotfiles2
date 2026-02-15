local gears = require("gears")
local awful = require("awful")
local keymaps = require("keymaps")
local wallpaper = require("wallpaper")
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.font = "sans 16"
root.keys(keymaps.globalkeys)

wallpaper.refresh()
awful.spawn.with_shell("killall picom ; picom --backend xrender --no-fading-openclose")
awful.spawn.once("setxkbmap gb extd")
awful.spawn.once("dunst")
awful.spawn.once("copyq")
awful.spawn.once("flameshot")
