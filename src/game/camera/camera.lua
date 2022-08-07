local Point = require("src.common.objects.point")

---@class Camera
local Camera = {}
Camera.__index = Camera

setmetatable(Camera, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Camera:init(o)
    ---@type Point
    self.center = Point(o.screen[1] / 2, o.screen[2] / 2)
    ---@type Point
    self.point = Point(0, 0)
end

function Camera:update(_)
    if self.object then
        local point = self.object:getMiddle()
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
    self.point = self.object:getMiddle()
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

function Camera:resize()
    local width, height = love.graphics.getDimensions()
    self.center = Point(width / 2, height / 2)
end

return Camera
