local Publisher = require("src.game.event.publisher")

local Container = require("src.gui.layout.container")
local Style = require("src.gui.style.style")
local Color = require("src.gui.style.property.color")
local Side = require("src.gui.style.property.side")
local Size = require("src.gui.style.property.size")
local TextView = require("src.gui.text-view")


---@class WaveCount : Container
local WaveCount = {}
WaveCount.__index = WaveCount

setmetatable(WaveCount, {
    __index = Container,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function WaveCount:init(o)
    ---@type integer
    self.currentWave = 1
    ---@type string
    self.selector = "wave"
    ---@type Element

    Container.init(self, {
        children = {
            TextView({
                id = self.selector,
                style = Style({
                    size = Size(235, 60),
                    padding = 20
                }),
                text = "Building phase...",
            })
        }
    })

    self.style = Style({
        color = Color(35, 35, 35, 0.9),
        size = Size(235, 60),
        margin = Side(0, 20, 0, 0),
    })

    Publisher.register(self, "wave.started", function(event) self:updateText("Wave " .. tostring(event:getPayload())) end)
    Publisher.register(self, "wave.countdown", function(event) self:updateText("Building phase: " .. tostring(event:getPayload())) end)
    Publisher.register(self, "wave.ended", function() self:updateText("Building phase...") end)
end

---Updates the wave text.
---@param text string
function WaveCount:updateText(text)
    local textView = self:querySelector("wave")
    ---@cast textView TextView
    textView.text = text
end

return WaveCount
