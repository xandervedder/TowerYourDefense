local GameObject = require("src.engine.object.gameobject")

Player = GameObject:new({
    position = { x = 128, y = 128 },
    controls = {
        up = false,
        down = false,
        left = false,
        right = false,
    },
    size = 32,
})

function Player:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", self.position.x, self.position.y, self.size)
    love.graphics.circle("line", self.position.x, self.position.y, self.size)
end

function Player:update(dt)
    if self.controls.up then self.position.y = self.position.y - 2 end
    if self.controls.down then self.position.y = self.position.y + 2 end
    if self.controls.left then self.position.x = self.position.x - 2 end
    if self.controls.right then self.position.x = self.position.x + 2 end
end

function Player:keyPressed(key)
    self:keyProcessor(key, true)
end

function Player:keyReleased(key)
    self:keyProcessor(key, false)
end

function Player:keyProcessor(key, on)
    if key == "up" then self.controls.up = on end
    if key == "down" then self.controls.down = on end
    if key == "left" then self.controls.left = on end
    if key == "right" then self.controls.right = on end
end

return Player
