local v = require("vars")

-- key: bind key, name: special workspace, app: desktop file id, class: window class
local pads = {
    { key = "q", name = "files",    app = "org.kde.dolphin",        class = "org.kde.dolphin" },
    { key = "w", name = "discord",  app = "com.discordapp.Discord", class = "discord" },
    { key = "e", name = "obsidian", app = "md.obsidian.Obsidian",   class = "obsidian" },
    { key = "r", name = "zotero",   app = "zotero",                 class = "Zotero" },
    { key = "t", name = "spotify",  app = "com.spotify.Client",     class = "Spotify" },
}

for _, p in ipairs(pads) do
    local ws = "special:" .. p.name

    -- Send the app to its scratchpad when it opens
    hl.window_rule({ match = { class = "^(" .. p.class .. ")$" }, workspace = ws .. " silent" })

    -- Gap around the overlay window
    hl.workspace_rule({ workspace = ws, gaps_out = 50 })

    -- Launch the app if the scratchpad is empty, then toggle it
    hl.bind(v.mod .. " + " .. p.key, function()
        if #hl.get_workspace_windows(ws) == 0 then
            hl.exec_cmd("gtk-launch " .. p.app, { workspace = ws .. " silent" })
        end
        hl.dispatch(hl.dsp.workspace.toggle_special(p.name))
    end)
end
