local M = {}

local gears = require("gears")
local awful = require("awful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local vars = require("vars")
local modkey = "Mod4"
local terminal = "alacritty"

local key = awful.key
M.globalkeys = gears.table.join(
    key({ modkey, }, "Return", function() awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }),
    key({ modkey, }, "/", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    key({ modkey, }, "j",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    key({ modkey, }, "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),

    -- Layout manipulation
    key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),
    key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),

    -- Standard program
    key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    key({ modkey, "Control" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    key({ modkey, }, "r", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),

    key({ modkey, "Control" }, "n",
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
    key({ modkey }, "space", function() menubar.show() end,
        { description = "show the menubar", group = "launcher" })
)

M.clientkeys = gears.table.join(
    key({ modkey, "Control" }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    key({ modkey, }, "w", function(c) c:kill() end,
        { description = "close", group = "client" }),
    key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),
    key({ modkey, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    key({ modkey, }, "m",
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

for _, tag in ipairs(vars.tags) do
    local tagKey = tag[2]
    local tagName = tag[1]
    M.globalkeys = gears.table.join(
        M.globalkeys,
        -- View tag only.
        key({ modkey }, tagKey,
            function() view_tag(tagName) end,
            { description = "view tag #" .. tagName, group = "tag" }),
        -- Toggle tag display.
        key({ modkey, "Control" }, tagKey,
            function() toggle_tag(tagName) end,
            { description = "toggle tag #" .. tagName, group = "tag" }),
        -- Move client to tag.
        key({ modkey, "Shift" }, tagKey,
            function() move_to_tag(tagName) end,
            { description = "move focused client to tag #" .. tagName, group = "tag" }),
        -- Toggle tag on focused client.
        key({ modkey, "Control", "Shift" }, tagKey,
            function() toggle_on_tag(tagName) end,
            { description = "toggle focused client on tag #" .. tagName, group = "tag" })
    )
end

return M
