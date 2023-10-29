local defineClass = require("src.common.objects.define-class")
local Point = require("src.common.objects.point")

local Util = require("src.game.util.util")

--[[
    Base Object used for any game object in the game.
    Whether it be an enemy or tower, every object inherits from GameObject.
]]--

---@class GameObject
local GameObject = defineClass()

--TODO: refactor the o to represent a type.
function GameObject:init(o)
    ---@type number
    self.obstructionRange = o.obstructionRange or 0
    ---@protected
    ---@type Point
    self.point = o.point or Point(0, 0)
    ---@protected
    ---@type Size
    self.size = o.size or Util.size(self.scale)
    ---@protected
    ---@type number
    self.speed = o.speed or 1
    ---@protected
    ---@type love.ImageData
    self.sheetData = nil
    ---@protected
    ---@type love.Image?
    self.sheet = nil

    ---@type string
    ---This is necessary since we cannot get the name of the metatable from lua itself.
    self.type = "GameObject"
    ---@type number
    self.scale = o.scale or 1
end

function GameObject:draw() end

---@param dt number
function GameObject:update(dt) end

---@param dt number
function GameObject:fixedUpdate(dt) end

function GameObject:getPoint()
    return self.point
end

---Returns the middle of the gameobject.
---@return Point
function GameObject:getMiddle()
    return Point(self.point.x + (self.size.w / 2), self.point.y + (self.size.h / 2))
end

---@param point Point
function GameObject:setPoint(point)
    self.point = point
end

---Gets the size.
---@return Size
function GameObject:getSize() return self.size end

---Sets the size according to the given scale
---@param scale number
function GameObject:setSize(scale)
    self.size = Util.size(scale)
end

---@return number
function GameObject:getSpeed() return self.speed end

---Stub method that is used to get images that together can represent a graphical
---representation of a gameobject.
---@return love.Image[]
function GameObject:toImages()
    error("Stub: method not implemented.")
end

---Utility method that creates images from its quads and sheet.
---@param imageData love.ImageData
---@param quads love.Quad[]
---@return love.Image[]
function GameObject.imagesFromQuads(imageData, quads)
    local images = {}
    for _, quad in pairs(quads) do
        local x, y, w, h = quad:getViewport()
        local data = love.image.newImageData(w, h)
        data:paste(imageData, 0, 0, x, y, w, h)
        table.insert(images, love.graphics.newImage(data))
    end
    return images
end

---Indicates whether the point given is within the obstruction range.
---This should be used when you want control over where something can be built, for example.
---@return boolean
---@param point Point This should be an actual coordinate -- not grid points (i.e. 64,64 instead of, 0,0)
function GameObject:isWithinObstructionRange(point)
    -- TODO: this should be a method on Point (maybe).
    local translated = Util.toGridPoint(self.point)
    if translated == point then return true end
    if self.obstructionRange == 0 then return false end

    ---@type Point
    local offset = Point(self.obstructionRange, self.obstructionRange)
    ---@type Point
    ---@diagnostic disable-next-line: assign-type-mismatch
    local topLeft = translated - offset
    ---@type Point
    ---@diagnostic disable-next-line: assign-type-mismatch
    local bottomRight = translated + offset

    return (point.x >= topLeft.x and point.x <= bottomRight.x) and
           (point.y >= topLeft.y and point.y <= bottomRight.y)
end

---Is the game object damageable?
---@return boolean
function GameObject:isDamageable() return false end

return GameObject
