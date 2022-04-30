---@class Camera
local Camera = {}

-- Requires a 'screen' attribute
-- e.g. Camera:new({ screen = { love.graphics.getDimensions() } })
function Camera:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.center = {
        x = o.screen[1] / 2,
        y = o.screen[2] / 2,
    }
    self.position = { x = 0, y = 0 }
    return o
end

function Camera:update(dt)
    if self.object then
        local position = self.object:getPosition()
        self.position.x = self.center.x + -position.x
        self.position.y = self.center.y + -position.y
    end
end

function Camera:draw()
    love.graphics.translate(self.position.x, self.position.y)
end

function Camera:followObject(object)
    self.object = object
    self.position.x = self.center.x - object:getSize().w / 2 -- In the middle of the object
    self.position.y = self.center.y - object:getSize().h
end

function Camera:getFollowObject()
    return self.object
end

function Camera:getCenter()
    return self.center
end

function Camera:getPosition()
    return self.position
end

return Camera
