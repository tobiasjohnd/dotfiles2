-- Train away from the mouse: it can't change focus or leave the focused monitor,
-- hides after HIDE seconds idle, then recentres in the focused window RECENTER seconds later
local HIDE = 2
hl.config({ input = { follow_mouse = 2, swallow_focus_click = true }, cursor = { inactive_timeout = HIDE } })
