local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local layoutbox = require("layoutbox")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
beautiful.init({
    font                     = "GohuFont, gothic 10",
    bg_normal                = "#101010",
    bg_urgent                = "#282828",
    fg_normal                = "#b9b9b9",
    fg_focus                 = "#f7f7f7",
    fg_urgent                = "#fb4934",
    useless_gap              = 4,
    border_width             = 1,
    border_normal            = "#464646",
    border_focus             = "#7c7c7c",
    prompt_fg                = "#f7f7f7",
    tasklist_fg_focus        = "#b9b9b9",
    tasklist_plain_task_name = true,
    tasklist_disable_icon    = true, })

modkey   = "Mod4"
terminal = "st tmux"

awful.layout.layouts = {
    awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Wibar
mystatus = wibox.widget.textbox()
awful.spawn.with_line_callback("i3status", { stdout = function (l) mystatus.markup = l end })
myghost = wibox.widget.textbox("<span foreground='#fe8019' font='Siji 8'></span> ")

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s)
    end
end

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    awful.tag({ "term", "www", "img", "doc", "misc" }, s, awful.layout.layouts[1])
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.noempty,
    }

    s.mypromptbox = awful.widget.prompt({ prompt = " ;;; " })

    s.mytasklist = wibox.container.constraint(
        awful.widget.tasklist {
            screen = s,
            filter = awful.widget.tasklist.filter.focused,
        }, "max", 600)
    
    s.mylayoutbox = layoutbox(s)
    
    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        {
            layout = wibox.layout.fixed.horizontal,
            myghost,
            s.mytasklist,
        },
        {
            layout = wibox.layout.fixed.horizontal,
            mystatus,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore, nil),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey,           }, "h",
        function ()
            awful.client.focus.global_bydirection("left")
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.global_bydirection("down")
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.global_bydirection("up")
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey,           }, "l",
        function ()
            awful.client.focus.global_bydirection("right")
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            if c then
                c:emit_signal("request::activate", "key.unminimize", {raise = true})
            end
        end),

    awful.key({ modkey, "Shift"   }, "h",      function () awful.client.swap.global_bydirection("left")  end),
    awful.key({ modkey, "Shift"   }, "j",      function () awful.client.swap.global_bydirection("down")  end),
    awful.key({ modkey, "Shift"   }, "k",      function () awful.client.swap.global_bydirection("up")    end),
    awful.key({ modkey, "Shift"   }, "l",      function () awful.client.swap.global_bydirection("right") end),

    awful.key({ modkey, "Control" }, "h",      function () awful.tag.incmwfact(-0.05)                    end),
    awful.key({ modkey, "Control" }, "l",      function () awful.tag.incmwfact( 0.05)                    end),
    awful.key({ modkey, "Control" }, "j",      function () awful.client.incwfact( 0.05)                  end),
    awful.key({ modkey, "Control" }, "k",      function () awful.client.incwfact(-0.05)                  end),
    
    awful.key({ modkey, "Shift"   }, "i",      function () awful.tag.incnmaster( 1, nil, true)           end),
    awful.key({ modkey, "Shift"   }, "o",      function () awful.tag.incnmaster(-1, nil, true)           end),
    awful.key({ modkey, "Control" }, "i",      function () awful.tag.incncol(    1, nil, true)           end),
    awful.key({ modkey, "Control" }, "o",      function () awful.tag.incncol(   -1, nil, true)           end),
    
    awful.key({ modkey,           }, "space",  function () awful.layout.inc( 1)                          end),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(-1)                          end),
    
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal)                         end),
    awful.key({ modkey,           }, "Prior",  function () awful.spawn("pamixer -i 1", false)            end),
    awful.key({ modkey,           }, "Next",   function () awful.spawn("pamixer -d 1", false)            end),
    awful.key({ modkey,           }, "r",      function () awful.screen.focused().mypromptbox:run()      end)
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen; c:raise()   end),
    awful.key({ modkey, "Shift"   }, "d",      function (c) c:kill()                                     end),
    awful.key({ modkey, "Control" }, "space",  function (c) c.floating = not c.floating                  end),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster())             end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop                        end),
    awful.key({ modkey, "Shift"   }, "n",      function (c) c.minimized = true                           end),
    awful.key({ modkey,           }, "m",      function (c) c.maximized = not c.maximized; c:raise()     end)
)

for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey                     }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end),
        awful.key({ modkey, "Control"          }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end),
        awful.key({ modkey, "Shift"            }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end)
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen },
      callback = awful.client.setslave
    },

    { rule_any = {
        role = {
          "AlarmWindow",
          "pop-up",
        }
      }, properties = { floating = true } },

    { rule = { class = "Firefox" },
      properties = { tag = "www", border_width = 0 } },

    { rule = { class = "mpv" },
      properties = { tag = "img", floating = true } },
}
-- }}}

-- {{{ Signals
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
