local wibox = require("wibox")
local menubar = require("menubar")
local awful = require("awful")

local vars = require("vars")
local keymaps = require("keymaps")

local batery = require("statusbar.battery")

menubar.utils.terminal = vars.terminal -- Set the terminal for applications that require it

awful.screen.connect_for_each_screen(function(s)
    for _, tag in ipairs(vars.tags) do
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
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = keymaps.taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = keymaps.tasklist_buttons
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
            batery(),
        },
    }
end)
-- }}}
