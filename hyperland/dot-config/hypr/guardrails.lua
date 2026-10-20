-- Train away from the mouse: it can't change focus or leave the focused monitor,
-- hides after HIDE seconds idle, then recentres in the focused window RECENTER seconds later
local HIDE, RECENTER = 2, 3
hl.config({ input = { follow_mouse = 3 }, cursor = { inactive_timeout = HIDE } })

local lx, ly, since = 0, 0, os.time()  -- last cursor position, and when it last changed
hl.timer(function()
    local m, p, w = hl.get_active_monitor(), hl.get_cursor_pos(), hl.get_active_window()
    if not m then return end
    local x = math.max(m.x, math.min(p.x, m.x + m.width / m.scale - 1))
    local y = math.max(m.y, math.min(p.y, m.y + m.height / m.scale - 1))
    if x ~= p.x or y ~= p.y then hl.dispatch(hl.dsp.cursor.move({ x = x, y = y })) end
    if p.x ~= lx or p.y ~= ly then lx, ly, since = p.x, p.y, os.time() end
    if w and os.time() - since >= HIDE + RECENTER + 1 then
        local cx, cy = w.at.x + w.size.x / 2, w.at.y + w.size.y / 2
        if math.abs(p.x - cx) > 1 or math.abs(p.y - cy) > 1 then hl.dispatch(hl.dsp.cursor.move({ x = cx, y = cy })) end
    end
end, { timeout = 10, type = "repeat" })
