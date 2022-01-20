local Constants = require("src.engine.constants")

local Tiles = {}
Tiles.tile = {}

function Tiles.initialize()
    Tiles.spriteSheet = love.graphics.newImage("/assets/graphics/tile-spritesheet.png")
    Tiles.spriteSheet:setFilter("nearest", "nearest")

    local tileWidth = Constants.tile.width
    local tileHeight = Constants.tile.height
    local width, height = Tiles.spriteSheet:getDimensions()
    local xTiles = width / tileWidth
    local yTiles = height / tileHeight

    print(xTiles, yTiles)

    for y = 1, yTiles, 1 do
        for x = 1, xTiles, 1 do
            table.insert(
                Tiles.tile,
                love.graphics.newQuad(
                    (x - 1) * tileWidth,
                    (y - 1) * tileHeight,
                    tileWidth,
                    tileHeight,
                    width,
                    height
                )
            )
        end
    end
end

return Tiles
