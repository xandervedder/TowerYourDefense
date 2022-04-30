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

function GameObject:init(o)
    self.position = o.position or { x = 0, y = 0 }
    self.size = o.size or Util.size()
    ---@type number
    self.speed = o.speed or 1
    ---@type love.ImageData
    self.sheetData = nil
    ---@type love.Image
    self.sheet = nil
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

function GameObject:getPosition()
    return self.position
end

function GameObject:getMiddle()
    return {
        x = self.position.x + (self.size.w / 2),
        y = self.position.y + (self.size.h / 2)
    }
end

function GameObject:setPosition(position)
    self.position = position
end

function GameObject:getSize() return self.size end

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

return GameObject
