local v = require("vars")

local STASH = "special:scratchpad" -- hidden parking, never shown

-- key: bind key, app: desktop file id, class: exact window class
local pads = {
    { key = "q", app = "org.kde.dolphin",        class = "org.kde.dolphin" },
    { key = "w", app = "com.discordapp.Discord", class = "discord" },
    { key = "e", app = "md.obsidian.Obsidian",   class = "obsidian" },
    { key = "r", app = "zotero",                 class = "Zotero" },
    { key = "t", app = "com.spotify.Client",     class = "Spotify" },
}

local function toggle(p)
    local w = hl.get_windows({ class = p.class })[1]
    if not w then return hl.exec_cmd("gtk-launch " .. p.app) end
    local sel   = "address:" .. w.address
    local shown = w.workspace.id == v.scratch_ws and w.workspace.visible
    hl.dispatch(hl.dsp.window.move({ window = sel, workspace = shown and STASH or v.scratch_ws, follow = false }))
    if not shown then hl.dispatch(hl.dsp.focus({ window = sel })) end
end

for _, p in ipairs(pads) do
    hl.window_rule({ match = { class = "^(" .. p.class .. ")$" }, workspace = tostring(v.scratch_ws) })
    hl.bind(v.mod .. " + " .. p.key, function() toggle(p) end)
end
