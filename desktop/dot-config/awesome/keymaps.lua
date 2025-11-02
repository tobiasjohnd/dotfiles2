local M = {}

local gears = require("gears")
local awful = require("awful")
local menubar = require("menubar")
local wallpaper = require("wallpaper")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local v = require("vars")

local key = awful.key
M.globalkeys = gears.table.join(
    key({ v.mod, }, "Return", function() awful.spawn(v.term) end,
        { description = "open a terminal", group = "launcher" }),
    key({ v.mod, }, "/", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    key({ v.mod, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    key({ v.mod, }, "j",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    key({ v.mod, }, "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),
    key({ v.mod }, "3", wallpaper.refresh,
        { description = "change wallpaper", group = "awesome" }),

    -- Layout manipulation
    key({ v.mod, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    key({ v.mod, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),
    key({ v.mod, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),

    -- Standard program
    key({ v.mod, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    key({ v.mod, "Control" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    key({ v.mod, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    key({ v.mod, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    key({ v.mod, }, "r", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),

    key({ v.mod, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Menubar
    key({ v.mod }, "space", function() menubar.show() end,
        { description = "show the menubar", group = "launcher" })
)

M.clientkeys = gears.table.join(
    key({ v.mod, "Control" }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    key({ v.mod, }, "w", function(c) c:kill() end,
        { description = "close", group = "client" }),
    key({ v.mod, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    key({ v.mod, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    key({ v.mod, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),
    key({ v.mod, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    key({ v.mod, }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" })
)

local function view_tag(label)
    local screen = awful.screen.focused()
    local tag = awful.tag.find_by_name(screen, label)
    if tag then
        tag:view_only()
    end
end

local function toggle_tag(label)
    local screen = awful.screen.focused()
    local tag = awful.tag.find_by_name(screen, label)
    if tag then
        awful.tag.viewtoggle(tag)
    end
end

local function move_to_tag(label)
    if client.focus then
        local screen = client.focus.screen
        local tag = awful.tag.find_by_name(screen, label)
        if tag then
            client.focus:move_to_tag(tag)
        end
    end
end

local function toggle_on_tag(label)
    if client.focus then
        local screen = client.focus.screen
        local tag = awful.tag.find_by_name(screen, label)
        if tag then
            client.focus:toggle_tag(tag)
        end
    end
end

for _, tag in ipairs(v.tags) do
    local tagKey = tag[2]
    local tagName = tag[1]
    M.globalkeys = gears.table.join(
        M.globalkeys,
        -- View tag only.
        key({ v.mod }, tagKey,
            function() view_tag(tagName) end,
            { description = "view tag #" .. tagName, group = "tag" }),
        -- Toggle tag display.
        key({ v.mod, "Control" }, tagKey,
            function() toggle_tag(tagName) end,
            { description = "toggle tag #" .. tagName, group = "tag" }),
        -- Move client to tag.
        key({ v.mod, "Shift" }, tagKey,
            function() move_to_tag(tagName) end,
            { description = "move focused client to tag #" .. tagName, group = "tag" }),
        -- Toggle tag on focused client.
        key({ v.mod, "Control", "Shift" }, tagKey,
            function() toggle_on_tag(tagName) end,
            { description = "toggle focused client on tag #" .. tagName, group = "tag" })
    )
end

return M
