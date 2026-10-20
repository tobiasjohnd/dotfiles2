local v = require("vars")

-- key: bind key, app: desktop file id, class: exact window class
local pads = {
    { key = "q", app = "org.kde.dolphin",        class = "org.kde.dolphin" },
    { key = "w", app = "com.discordapp.Discord", class = "discord" },
    { key = "e", app = "md.obsidian.Obsidian",   class = "obsidian" },
    { key = "r", app = "zotero",                 class = "Zotero" },
    { key = "t", app = "com.spotify.Client",     class = "Spotify" },
}

-- ws 5 shows one fullscreen window at a time; a key raises its app (or launches it)
hl.workspace_rule({ workspace = tostring(v.scratch_ws), layout = "monocle" })

for _, p in ipairs(pads) do
    hl.window_rule({ match = { class = "^(" .. p.class .. ")$" }, workspace = tostring(v.scratch_ws) })
    hl.bind(v.mod .. " + " .. p.key, function()
        local w = hl.get_windows({ class = p.class })[1]
        if w then hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address })) else hl.exec_cmd("gtk-launch " .. p.app) end
    end)
end
