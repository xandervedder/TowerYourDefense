local Point = require("src.common.objects.point")

local Constants = require("src.game.constants")

---@class Util
local Util = {}

---Translates a point from the mouse to something that could be used by the game.
---
---For example: mouse 64, 46 -> grid 0, 0 -> point 64, 64
---@param x any
---@param y any
---@return Point
function Util.fromMousePoint(x, y)
    x = math.floor(x / Constants.tile.scaledWidth())
    y = math.floor(y / Constants.tile.scaledHeight())

    return Util.fromCoordinate(x, y)
end

---Transforms a (1, 0) 'coordinate' to the equivalent Point in-game (1 * size * scale, ...).
---@param x number
---@param y number
---@return Point
function Util.fromCoordinate(x, y)
    return Point(x * Constants.tile.scaledWidth(), y * Constants.tile.scaledHeight())
end

---Converts a `real` point to a grid `point`.
---For example, we can convert (16*8, 16*,8) to (0, 0)
---@param point Point|nil
---@param x number|nil
---@param y number|nil
---@return Point
function Util.toGridPoint(point, x, y)
    if point ~= nil then
        x = point.x
        y = point.y
    end

    local height = Constants.tile.scaledHeight()
    local width = Constants.tile.scaledWidth()
    return Point(math.floor(x / width), math.floor(y / height))
end

function Util.size(scale)
    scale = scale or 1
    return {
        w = Constants.tile.scaledWidth() * scale,
        h = Constants.tile.scaledHeight() * scale,
    }
end

---Checks if the first object is within the other object.
---@param o1 GameObject The first object
---@param o2 GameObject The object to compare the point to
function Util.isWithin(o1, o2)
    local p1 = o1:getPoint()
    local p2 = o2:getPoint()
    local s2 = o2:getSize()

    return (p1.x > p2.x and p1.x < p2.x + s2.w) and
        (p1.y > p2.y and p1.y < p2.y + s2.h)
end

--TODO: this should really be a method within a Point or Location class...
---Checks if position 1 is within position 2.
---@param p1 Point
---@param p2 Point
---@param s2 Size
function Util.isWithinPosition(p1, p2, s2)
    return (p1.x > p2.x and p1.x < p2.x + s2.w) and (p1.y > p2.y and p1.y < p2.y + s2.h)
end

return Util
