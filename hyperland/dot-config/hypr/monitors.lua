local v = require("vars")

-- ws 1-4 live on the external monitor if there is one, else the laptop; ws 5 is always the laptop
local function assign(gone)
    local home = v.laptop
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= v.laptop and m.name ~= gone then home = m.name end
    end
    for i = 1, 5 do
        hl.workspace_rule({ workspace = tostring(i), monitor = i == 5 and v.laptop or home, persistent = true })
    end
end

assign()
hl.on("monitor.added", function() assign() end)
hl.on("monitor.removed", function(m) assign(m.name) end)
