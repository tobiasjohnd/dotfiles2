local res = screen.primary.geometry

local url = string.format("https://picsum.photos/%s/%s", res.width, res.height)
local wallpapers_home = os.getenv("HOME") .. "/wallpapers"
local cmd_wall_pick = string.format("find %s -type f | shuf -n 1", wallpapers_home)

local function refresh()
    local handle = io.popen(cmd_wall_pick)
    local wallpaper_path = handle:read("*l")
    handle:close()

    if wallpaper_path == nil or wallpaper_path == "" then
        wallpaper_path = wallpapers_home .. "/wallpaper.jpg"
        os.execute(string.format('curl -L -o "%s" "%s"', wallpaper_path, url))
    end
    require("gears.wallpaper").maximized(wallpaper_path)
end

return { refresh = refresh }

--- wishlist ---

-- delete wallpapers
-- auto create wallpapers_home if it doesnt exist
-- open current wallpaper for editing
