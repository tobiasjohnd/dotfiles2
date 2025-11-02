local gears = require("gears")
local awful = require("awful")
local keymaps = require("keymaps")
local vars = require("vars")
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
root.keys(keymaps.globalkeys)

gears.wallpaper.maximized(vars.wallpaper_path)
awful.spawn.with_shell("killall picom ; picom --no-fading-openclose")
