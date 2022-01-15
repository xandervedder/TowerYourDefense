local Constants = require("src.engine.constants")
local GameObject = require("src.engine.object.gameobject")

Enemy = GameObject:new({ health = 100, speed = 10, size = 8 })

function Enemy:initialize() end

function Enemy:draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle(
        "fill",
        self.position.x,
        self.position.y,
        self.size * Constants.scale
    )
end

function Enemy:update(dt)
    -- TODO: calculate speed in a better way
    self.position.y = self.position.y + self.speed / 3
end

return Enemy
