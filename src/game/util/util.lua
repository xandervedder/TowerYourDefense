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

function Util.size()
    return {
        w = Constants.tile.scaledWidth(),
        h = Constants.tile.scaledHeight(),
    }
end

return Util
