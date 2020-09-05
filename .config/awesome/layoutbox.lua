---------------------------------------------------------------------------
--- Layoutbox widget.
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @classmod awful.widget.layoutbox
---------------------------------------------------------------------------

local setmetatable = setmetatable
local capi = { screen = screen, tag = tag }
local layout = require("awful.layout")
local wibox = require("wibox")

local function get_screen(s)
    return s and capi.screen[s]
end

local layoutbox = { mt = {} }

local boxes = nil

local icon = {
    fairv      = "",
    fairh      = "",
    tile       = "",
    tileleft   = "",
    tiletop    = "",
    tilebottom = "",
    spiral     = "",
    dwindle    = "",
    floating   = "",
    max        = "",
    magnifier  = "",

    __index = function(t, k) return k end
}
setmetatable(icon, icon)
    
local function update(w, screen)
    screen = get_screen(screen)
    local name = layout.getname(layout.get(screen))

    w.markup = "<span foreground='#928374' font='Siji 8'>"..icon[name].."</span>"
end

local function update_from_tag(t)
    local screen = get_screen(t.screen)
    local w = boxes[screen]
    if w then
        update(w, screen)
    end
end

function layoutbox.new(screen)
    screen = get_screen(screen or 1)

    if boxes == nil then
        boxes = setmetatable({}, { __mode = "kv" })
        capi.tag.connect_signal("property::selected", update_from_tag)
        capi.tag.connect_signal("property::layout", update_from_tag)
        capi.tag.connect_signal("property::screen", function()
            for s, w in pairs(boxes) do
                if s.valid then
                    update(w, s)
                end
            end
        end)
        layoutbox.boxes = boxes
    end

    local w = boxes[screen]
    if not w then
        w = wibox.widget.textbox()
        update(w, screen)
        boxes[screen] = w
    end

    return w
end

function layoutbox.mt:__call(...)
    return layoutbox.new(...)
end

return setmetatable(layoutbox, layoutbox.mt)
