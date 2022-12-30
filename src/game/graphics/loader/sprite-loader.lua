local Constants = require("src.game.constants")

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
        mech = self.prepareSprite(self.SPRITE_SHEETS.MECH, 32, 32),
    }
end

---@class Sprite
---@field imageData love.ImageData
---@field image love.Image
---@field quads love.Quad[]

---Loads and returns the image with accompanied imageData.
---@private
---@param location string
---@param width integer?
---@param height integer?
---@return Sprite
function SpriteLoader.prepareSprite(location, width, height)
    width = width or Constants.tile.w
    height = height or Constants.tile.h
    local imageData = love.image.newImageData(location)
    local image = love.graphics.newImage(imageData)
    image:setFilter("nearest", "nearest")
    return {
        imageData = imageData,
        image = image,
        quads = SpriteLoader.prepareQuads(imageData, width, height)
    }
end

---Loads all the possible quads that could be in the spritesheet.
---@private
---@param imageData love.ImageData
---@param width integer
---@param height integer
---@return love.Quad[]
function SpriteLoader.prepareQuads(imageData, width, height)
    local imageWidth, imageHeight = imageData:getDimensions()
    local imageWidthIndex = imageWidth / width
    local imageHeightIndex = imageHeight / height
    local quads = {}
    for i = 0, imageHeightIndex - 1, 1 do
        for j = 0, imageWidthIndex - 1, 1 do
            local quad = love.graphics.newQuad(
                j * width,
                i * height,
                width,
                height,
                imageWidth,
                imageHeight
            )

            table.insert(quads, quad)
        end
    end

    return quads
end

---Gets the sprite with the given name.
---@param name string
---@return Sprite
function SpriteLoader.getSprite(name)
    local self = SpriteLoader
    return self.data[name]
end

return SpriteLoader
