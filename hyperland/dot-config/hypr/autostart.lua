local v = require("vars")

-- Runs on every config load
hl.exec_cmd("killall waybar ; waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/style.css")

-- Runs once at startup
hl.on("hyprland.start", function()
    hl.exec_cmd(v.scripts .. "/waybar-controller.sh")
    hl.exec_cmd(v.scripts .. "/wallpaper.sh")
end)
