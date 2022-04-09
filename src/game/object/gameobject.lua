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
    self.speed = o.speed or 1
end

---Loads the sheet and assigns it to self.sheet.
---@param location string
---@param filterType string
function GameObject:setSheet(location, filterType)
    filterType = filterType or "nearest"
    self.sheet = love.graphics.newImage(location)
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

---@return love.Image[]
function GameObject:getSheets() end

---@return love.Quad[]
function GameObject:getQuads() end

return GameObject
