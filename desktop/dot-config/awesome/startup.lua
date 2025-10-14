local gears = require("gears")
local awful = require("awful")
local keymaps = require("keymaps")
local vars = require("vars")
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
root.keys(keymaps.globalkeys)

awful.spawn.with_shell(vars.wallpaper)
awful.spawn.with_shell("killall picom ; picom --no-fading-openclose")
awful.spawn.with_shell("killall pipewire ; pipewire")
