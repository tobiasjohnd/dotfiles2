local res = screen.primary.geometry
local url = string.format("https://picsum.photos/%s/%s", res.width, res.height)
local wallpaper_path = os.getenv("HOME") .. "/wallpaper.jpg"
local cmd = string.format('curl -L -o "%s" "%s"', wallpaper_path, url)

local function refresh()
    os.execute(cmd)
    require("gears.wallpaper").maximized(wallpaper_path)
end

return { refresh = refresh }
