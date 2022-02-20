local Enemy = require("src.engine.object.enemy")
local Event = require("src.engine.event.event")
local GameObject = require("src.engine.object.gameobject")
local Publisher = require("src.engine.event.publisher")

Spawner = GameObject:new()
-- Table with tables
Spawner.enemies = {}

function Spawner:initialize()
    self.deltaPassed = 0
    self.spawnRate = self.spawnRate or 1 -- In seconds

    self.register(self)
    self.enemies = self.getEnemies(self)

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
        },
        parent = self,
    })
    enemy:initialize()
    table.insert(self.enemies, enemy)
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

function Spawner.register(instance)
    Spawner.enemies[instance] = {}
end

function Spawner.removeEnemy(event)
    local enemyRef = event:getData()
    local eTable = Spawner.enemies[enemyRef.parent]
    for i = #eTable, 1, -1 do
        local enemy = eTable[i]
        if enemy == enemyRef then
            table.remove(eTable, i)
        end
    end
end

function Spawner.getEnemies(instance)
    return Spawner.enemies[instance]
end

function Spawner.allEnemies()
    local flatEnemiesList = {}
    for _, eTable in pairs(Spawner.enemies) do
        for _, enemy in pairs(eTable) do
            table.insert(flatEnemiesList, enemy)
        end
    end
    return flatEnemiesList
end

Publisher.register(Spawner, "enemy.death", Spawner.removeEnemy)

return Spawner
