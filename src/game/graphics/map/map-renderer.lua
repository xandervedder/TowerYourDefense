local json = require("lunajson")

local defineClass = require("src.common.objects.define-class")
local Point = require("src.common.objects.point")

local C = require("src.game.constants")

--TODO: Move from 'gui' to 'common'
local Size = require("src.gui.style.property.size")

---@class Tile
---@field background table<number>
---@field shrubbery table<number>
---@field collidable table<number>
---@field shades table<table<number>>

---@class TileQuad
---@field background love.Quad?
---@field shrubbery love.Quad?
---@field collidable love.Quad?
---@field shades love.Quad?

---@class MapRenderer
local MapRenderer = defineClass()
MapRenderer.LEVEL_DIRECTORY = "/assets/map/"
MapRenderer.TILE_DIRECTORY = "/assets/graphics/tiles/"
MapRenderer.TILE_MAPS = {
    BACKGROUND = MapRenderer.TILE_DIRECTORY .. "background-tiles.png",
    COLLIDABLE = MapRenderer.TILE_DIRECTORY .. "collidable-tiles.png",
    SHADES = MapRenderer.TILE_DIRECTORY .. "shade-tiles.png",
    SHRUBBERY = MapRenderer.TILE_DIRECTORY .. "shrubbery-tiles.png",
}

---Constructor.
function MapRenderer:init()
    -- For some reason, we cannot directly insert the string that
    -- comes from the love.filesystem.read() method.
    ---@private
    self.levelDataString = love.filesystem.read(self.LEVEL_DIRECTORY .. "main.json")
    ---@private
    ---@type Tile[][]
    self.levelDataJson = json.decode(self.levelDataString)
    ---@private
    self.sheets = {
        background = love.graphics.newImage(self.TILE_MAPS.BACKGROUND),
        collidable = love.graphics.newImage(self.TILE_MAPS.COLLIDABLE),
        shades = love.graphics.newImage(self.TILE_MAPS.SHADES),
        shrubbery = love.graphics.newImage(self.TILE_MAPS.SHRUBBERY),
    }
    for _, sheet in pairs(self.sheets) do
        sheet:setFilter("nearest", "nearest")
    end

    self:prepareQuads()
end

---Prepares the quads before they can be rendered.
function MapRenderer:prepareQuads()
    ---@type TileQuad[][]
    self.quads = {}
    for _, row in pairs(self.levelDataJson) do
        ---@type TileQuad[]
        local quadRow = {}
        for _, tile in pairs(row) do
            ---@type TileQuad
            local quads = {
                background = nil,
                collidable = nil,
                shades = nil,
                shrubbery = nil,
            }

            if tile.background ~= nil then
                quads.background = self:getQuad(self:getTileCoordinates(tile.background), self.sheets.background)
            end
            if tile.collidable ~= nil then
                quads.collidable = self:getQuad(self:getTileCoordinates(tile.collidable), self.sheets.collidable)
            end
            if tile.shades ~= nil then
                quads.shades = {}
                for _, shade in pairs(tile.shades) do
                    table.insert(quads.shades, self:getQuad(self:getTileCoordinates(shade), self.sheets.shades))
                end
            end
            if tile.shrubbery ~= nil then
                quads.shrubbery = self:getQuad(self:getTileCoordinates(tile.shrubbery), self.sheets.shrubbery)
            end

            table.insert(quadRow, quads)
        end

        table.insert(self.quads, quadRow)
    end
end

---Returns the calculated coordinates from an array.
---@param tile table<number>
---@return Point
function MapRenderer:getTileCoordinates(tile)
    local x = tile[1]
    local y = tile[2]
    return Point(x * C.tile.w, y * C.tile.h)
end

---Gets the quad that this is associated to the sheet.
---@param tile Point
---@param sheet love.Image
---@return love.Quad
function MapRenderer:getQuad(tile, sheet)
    local width, height = sheet:getDimensions()
    return love.graphics.newQuad(tile.x, tile.y, C.tile.w, C.tile.h, width, height)
end

---Drawing method of the MapRenderer.
function MapRenderer:draw()
    for x, quadRow in pairs(self.quads) do
        for y, quad in pairs(quadRow) do
            if quad.background ~= nil then
                self:drawQuad(self.sheets.background, quad.background, x, y)
            end
            if quad.collidable ~= nil then
                self:drawQuad(self.sheets.collidable, quad.collidable, x, y)
            end
            if quad.shades ~= nil then
                for _, shadeQuad in pairs(quad.shades) do
                    self:drawQuad(self.sheets.shades, shadeQuad, x, y)
                end
            end
            if quad.shrubbery ~= nil then
                self:drawQuad(self.sheets.shrubbery, quad.shrubbery, x, y)
            end
        end
    end
end

---Helper method that draws a Quad.
---@param sheet love.Image
---@param quad love.Quad
---@param x number
---@param y number
function MapRenderer:drawQuad(sheet, quad, x, y)
    love.graphics.draw(
        sheet,
        quad,
        (y - 1) * C.tile.scaledHeight(),
        (x - 1) * C.tile.scaledWidth(),
        0,
        C.scale,
        C.scale
    )
end

---Gets the dimensions of the to be rendered map.
---@return Size
function MapRenderer:getDimensions()
    return Size(C.tile.scaledWidth() * #self.quads[1], (C.tile.scaledHeight() * #self.quads))
end

---Gets the grid size of the map, which tells how many cells are within the map.
---
---Note: not the *actual* size of the map.
---@return Size
function MapRenderer:getGridSize()
    return Size(#self.quads[1], #self.quads)
end

return MapRenderer
