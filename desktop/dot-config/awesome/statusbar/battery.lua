local awful = require("awful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

local HOME = os.getenv("HOME")
local WIDGET_DIR = HOME .. '/.config/awesome/awesome-wm-widgets/battery-widget'

-- bodge fix for namespace issue why the fuck they decided to change this is beyond me.
-- this can be remove after update to v4.4
local lgi = require("lgi")
local Gio = lgi.Gio
local GioUnix = lgi.GioUnix
if not Gio.UnixInputStream and GioUnix then
    Gio.UnixInputStream = GioUnix.InputStream
    Gio.UnixOutputStream = GioUnix.OutputStream
end

local battery_widget = {}
local function worker(user_args)
    local margin_left = 0
    local margin_right = 0

    local timeout = 10

    local level_widget = wibox.widget {
        widget = wibox.widget.textbox
    }

    battery_widget = wibox.widget {
        level_widget,
        layout = wibox.layout.fixed.horizontal,
    }

    local handle = io.popen("acpi -i")
    if handle then
        local output = handle:read("*a") -- reads all
        handle:close()
        -- process output
        naughty.notify({ text = output })
    end
    watch("acpi -i", timeout,
        function(widget, stdout)
            local battery_info = {}
            local capacities = {}
            for s in stdout:gmatch("[^\r\n]+") do
                -- Match a line with status and charge level
                local status, charge_str, _ = string.match(s, '.+: ([%a%s]+), (%d?%d?%d)%%,?(.*)')
                if status ~= nil then
                    -- Enforce that for each entry in battery_info there is an
                    -- entry in capacities of zero. If a battery has status
                    -- "Unknown" then there is no capacity reported and we treat it
                    -- as zero capactiy for later calculations.
                    table.insert(battery_info, { status = status, charge = tonumber(charge_str) })
                    table.insert(capacities, 0)
                end

                -- Match a line where capacity is reported
                local cap_str = string.match(s, '.+:.+last full capacity (%d+)')
                if cap_str ~= nil then
                    capacities[#capacities] = tonumber(cap_str) or 0
                end
            end

            local capacity = 0
            local charge = 0
            local status
            for i, batt in ipairs(battery_info) do
                if capacities[i] ~= nil then
                    if batt.charge >= charge then
                        status = batt.status -- use most charged battery status
                        -- this is arbitrary, and maybe another metric should be used
                    end

                    -- Adds up total (capacity-weighted) charge and total capacity.
                    -- It effectively ignores batteries with status "Unknown" as we
                    -- treat them with capacity zero.
                    charge = charge + batt.charge * capacities[i]
                    capacity = capacity + capacities[i]
                end
            end
            charge = charge / capacity

            if status == 'Charging' then
                level_widget.text = string.format('(%d%%)', charge)
            elseif status == 'Discharging' then
                level_widget.text = string.format('%d%%', charge)
            elseif status == 'Full' then
                level_widget.text = string.format('', charge)
            end
        end,
        level_widget)

    return wibox.container.margin(battery_widget, margin_left, margin_right)
end

return setmetatable(battery_widget, { __call = function(_, ...) return worker(...) end })
