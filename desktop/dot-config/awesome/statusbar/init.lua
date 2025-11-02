local wibox = require("wibox")
local menubar = require("menubar")
local awful = require("awful")
local gears = require("gears")

local v = require("vars")

local battery = require("statusbar.battery")

menubar.utils.terminal = v.term -- Set the terminal for applications that require it
local modkey = v.mod

awful.screen.connect_for_each_screen(function(s)
    for _, tag in ipairs(v.tags) do
        local tagname = tag[1]
        local taglayout = tag[3]
        local selected = (tagname == "main")
        awful.tag.add(tagname, {
            screen = s,
            layout = taglayout,
            selected = selected,
        }
        )
    end

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        {             -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            battery(),
        },
    }
end)
-- }}}
