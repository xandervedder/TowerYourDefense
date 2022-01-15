local Enemy = require("src.engine.object.enemy")
local Event = require("src.engine.event.event")
local GameObject = require("src.engine.object.gameobject")
local Publisher = require("src.engine.event.publisher")

Spawner = GameObject:new()

function Spawner:initialize()
    self.deltaPassed = 0
    self.spawnRate = 2 -- In seconds
    self.enemies = {}
end

function Spawner:draw()
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle(
        "fill",
        self.position.x,
        self.position.y,
        Constants.tile.scaledWidth(),
        Constants.tile.scaledHeight()
    )

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("SPAWNER", self.position.x, self.position.y)

    self:drawSpawnedEnemies()
end

function Spawner:drawSpawnedEnemies()
    for i = 1, #self.enemies, 1 do
        self.enemies[i]:draw()
    end
end

function Spawner:update(dt)
    self.deltaPassed = self.deltaPassed + dt
    if self.deltaPassed >= self.spawnRate then
        self.deltaPassed = 0
        self:spawn()
    end

    self:despawnOutOfBoundsEnemies()
    self:updateSpawnedEnemies(dt)
end

function Spawner:spawn()
    local enemy = Enemy:new({
        position = {
            x = self.position.x + Constants.tile.scaledWidth() / 2,
            y = self.position.y + Constants.tile.scaledHeight() / 2
        }
    })
    table.insert(self.enemies, enemy)

    Publisher.publish(Event:new({ name = "events.enemy.follow", data = enemy }))
end

function Spawner:despawnOutOfBoundsEnemies()
    local x, y = love.graphics.getDimensions()
    for i = #self.enemies, 1, -1 do
        local position = self.enemies[i]:getPosition()
        if position.x > x or position.y > y then
            table.remove(self.enemies, i)
        end
    end
end

function Spawner:updateSpawnedEnemies(dt)
    for i = 1, #self.enemies, 1 do
        self.enemies[i]:update(dt)
    end
end

return Spawner
