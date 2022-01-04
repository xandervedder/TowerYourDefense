local GameObject = require("src.engine.object.gameobject")

Player = GameObject:new()

function Player:draw()

end

function Player:update()

end

function Player:getName()
    print(self.name)
end

return Player
