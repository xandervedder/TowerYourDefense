local Point = require("src.common.objects.point")

local Util = require("src.game.util.util")

--[[
    Base Object used for any game object in the game.
    Whether it be an enemy or tower, every object inherits from GameObject.
]]--

---@class GameObject
local GameObject = {}
GameObject.__index = GameObject

setmetatable(GameObject, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

--TODO: refactor the o to represent a type.
function GameObject:init(o)
    ---@type number
    self.obstructionRange = o.obstructionRange or 0
    ---@type Point
    self.point = o.point or Point(0, 0)
    ---@type number
    self.scale = o.scale or 1
    ---@type Size
    self.size = o.size or Util.size(self.scale)
    ---@type number
    self.speed = o.speed or 1
    ---@type love.ImageData
    self.sheetData = nil
    ---@type love.Image
    self.sheet = nil
    ---@type string
    ---This is necessary since we cannot get the name of the metatable from lua itself.
    self.type = "GameObject"
end

---Loads the sheet and assigns both the imageData and Image to the object.
---@param location string
---@param filterType? string
function GameObject:setSheet(location, filterType)
    -- TODO: move to constructor
    filterType = filterType or "nearest"
    self.sheetData = love.image.newImageData(location)
    self.sheet = love.graphics.newImage(self.sheetData)
    self.sheet:setFilter(filterType, filterType)
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

function GameObject:getSize() return self.size end

---Sets the size according to the given scale
---@param scale number
function GameObject:setSize(scale)
    self.size = Util.size(scale)
end

function GameObject:getSpeed() return self.speed end

---@deprecated
---@return love.Image[]
function GameObject:getSheets() end

---@return love.Quad[]
function GameObject:getQuads() end

---Stub method that is used to return images of the game src.game.object.base
---This is useful for external usages of the game objects, since they no longer
---need to make the images by themselves with quads et cetera.
---@return love.Image[]
function GameObject:toImage() end

---Utility method that creates images from its quads and sheet.
---@param sheet love.ImageData
---@param quads love.Quad[]
---@return love.Image[]
function GameObject.imagesFromQuads(sheet, quads)
    local images = {}
    for _, quad in pairs(quads) do
        local x, y, w, h = quad:getViewport()
        local data = love.image.newImageData(w, h)
        data:paste(sheet, 0, 0, x, y, w, h)
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
