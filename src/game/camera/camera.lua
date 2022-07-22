local Point = require("src.common.objects.point")

---@class Camera
local Camera = {}

-- TODO: use new way of making a class in lua.
-- Requires a 'screen' attribute
-- e.g. Camera:new({ screen = { love.graphics.getDimensions() } })
function Camera:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    ---@type Point
    self.center = Point(o.screen[1] / 2, o.screen[2] / 2)
    ---@type Point
    self.point = Point(0, 0)
    return o
end

function Camera:update(dt)
    if self.object then
        local point = self.object:getPoint()
        self.point.x = self.center.x + -point.x
        self.point.y = self.center.y + -point.y
    end
end

function Camera:draw()
    love.graphics.translate(self.point.x, self.point.y)
end

function Camera:followObject(object)
    ---@type GameObject
    self.object = object
    self.point.x = self.center.x - object:getSize().w / 2 -- In the middle of the object
    self.point.y = self.center.y - object:getSize().h
end

function Camera:getFollowObject()
    return self.object
end

function Camera:getCenter()
    return self.center
end

function Camera:getPoint()
    return self.point
end

return Camera
