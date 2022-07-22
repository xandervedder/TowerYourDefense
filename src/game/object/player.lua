local GameObject = require("src.game.object.gameobject")

---@class Player : GameObject
local Player = {}
Player.__index = Player

setmetatable(Player, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Player:init(o)
    GameObject.init(self, o)

    self.controls = {
        up = false,
        down = false,
        left = false,
        right = false,
        hide = false,
    }
end

function Player:draw()
    if self.controls.hide then return end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.point.x, self.point.y, self.size.w / 2, self.size.h / 2)
end

function Player:update(dt)
    if self.controls.up then self.point.y = self.point.y - 2 end
    if self.controls.down then self.point.y = self.point.y + 2 end
    if self.controls.left then self.point.x = self.point.x - 2 end
    if self.controls.right then self.point.x = self.point.x + 2 end
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
    if key == "h" then self.controls.hide = on end
end

return Player
