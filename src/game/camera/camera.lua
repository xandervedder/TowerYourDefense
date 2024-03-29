local defineClass = require("src.common.objects.define-class")
local Point = require("src.common.objects.point")

local Constants = require("src.game.constants")

---@class Camera
local Camera = defineClass()

---Constructor.
function Camera:init()
    local height = love.graphics.getHeight()
    local width = love.graphics.getWidth()
    ---@private
    ---@type Point
    self.screen = Point(width, height)
    ---@private
    ---@type Point
    self.offset = Point(Constants.world.w - width, Constants.world.h - height)
    ---@private
    ---@type Point
    self.point = Point(0, 0)
end

---Draw method of the camera.
function Camera:draw()
    love.graphics.translate(-self.point.x, -self.point.y)
end

---Update method of the camera.
function Camera:update()
    if not self.object then return end

    local point = self.object:getMiddle()
    self.point.x = math.clamp(point.x - self.screen.x / 2, 0, self.offset.x)
    self.point.y = math.clamp(point.y - self.screen.y / 2, 0, self.offset.y)
end

---Allows the camera to follow a gameObject.
---@param object GameObject
function Camera:followObject(object)
    ---@type GameObject
    self.object = object
    self.point = self.object:getMiddle()
end

---Resize method of the camera.
function Camera:resize()
    local width, height = love.graphics.getDimensions()
    self.screen = Point(width, height)
end

---Returns the mousePosition relative to the camera.
---@return Point
function Camera:mousePosition()
  return Point(love.mouse.getX() + self.point.x, love.mouse.getY() + self.point.y)
end

return Camera
