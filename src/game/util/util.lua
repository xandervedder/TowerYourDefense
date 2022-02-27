local Constants = require("src.game.constants")

local Util = {}

function Util.position(x, y)
    local yPos = y * Constants.tile.scaledHeight()
    local xPos = x * Constants.tile.scaledWidth()

    return {
        grid = { x = x, y = y },
        position = { x = xPos, y = yPos, },
    }
end

function Util.size(scale)
    scale = scale or 1
    return {
        w = Constants.tile.scaledWidth() / scale,
        h = Constants.tile.scaledHeight() /scale,
    }
end

---Checks if the first object is within the other object.
---@param o1 table The first object
---@param o2 table The object to compare the position to
function Util.isWithin(o1, o2)
    local p1 = o1:getPosition()
    local p2 = o2:getPosition()
    local s2 = o2:getSize()

    return (p1.x > p2.x and p1.x < p2.x + s2.w) and
        (p1.y > p2.y and p1.y < p2.y + s2.h)
end

return Util
