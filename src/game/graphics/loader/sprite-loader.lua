--[[
    SpriteLoader for TowerYourDefense.
    This should be the only place where images are loaded, only loads the images once.
]]

---@class SpriteLoader
local SpriteLoader = {}
SpriteLoader.__index = SpriteLoader
SpriteLoader.SPRITE_SHEETS = {
    COLLECTION = "assets/graphics/collection-spritesheet.png",
    TOWER_BASE = "assets/graphics/tower-base-spritesheet.png",
    TURRET = "assets/graphics/turret-spritesheet.png",
    MECH = "assets/graphics/mech/mech.png",
}

---@private
SpriteLoader.data = {}

---Initialization method of the Spriteloader.
---It is important to note that this method
---should only be called when love is initialized (love.load()).
function SpriteLoader.init()
    local self = SpriteLoader

    ---@private
    self.data = {
        collection = self.prepareSprite(self.SPRITE_SHEETS.COLLECTION),
        base = self.prepareSprite(self.SPRITE_SHEETS.TOWER_BASE),
        turret = self.prepareSprite(self.SPRITE_SHEETS.TURRET),
        mech = self.prepareSprite(self.SPRITE_SHEETS.MECH),
    }
end

---@class Sprite
---@field imageData love.ImageData
---@field image love.Image

---Loads and returns the image with accompanied imageData.
---@private
---@param location string
---@return Sprite
function SpriteLoader.prepareSprite(location)
    local imageData = love.image.newImageData(location)
    local image = love.graphics.newImage(imageData)
    image:setFilter("nearest", "nearest")
    return { imageData = imageData, image = image }
end

---Gets the sprite with the given name.
---@param name string
---@return Sprite
function SpriteLoader.getSprite(name)
    local self = SpriteLoader
    return self.data[name]
end

return SpriteLoader
