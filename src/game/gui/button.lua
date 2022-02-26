local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")

Button = {}

function Button:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.text = o.text or ""
    self.event = o.event or Event:new({ name = "events.unknown" })
    self.size = { w = 350, h = 150 }
    self.position = o.position or { x = 25, y = 25 }
    self.mouseWithinBounds = false
    return o
end

function Button:initialize()
    local x, _ = love.graphics.getDimensions()
    self.position.x = (x / 2) - (self.size.w / 2)
end

function Button:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        "fill",
        self.position.x,
        self.position.y,
        self.size.w,
        self.size.h
    )

    local text = love.graphics.newText(love.graphics.newFont(24), self.text)
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(
        text,
        self.position.x + (self.size.w / 2) - (text:getWidth() / 2),
        self.position.y + (self.size.h / 2) - 12
    )
end

function Button:mousePressed()
    local x, y = love.mouse.getPosition()
    if x < self.position.x then return end
    if y < self.position.y then return end

    if (x == self.position.x or x < self.position.x + self.size.w) and
       (y == self.position.y or y < self.position.y + self.size.h)
    then
        self.mouseWithinBounds = true
    else
        self.mouseWithinBounds = false
    end
end

function Button:mouseReleased()
    if self.mouseWithinBounds then
        Publisher.publish(self.event)
    end
end

return Button
