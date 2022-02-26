local Enemy = require("src.game.object.enemy")
local GameObject = require("src.game.object.gameobject")
local Publisher = require("src.game.event.publisher")

local Spawner = {}
Spawner.enemies = {}
Spawner.__index = Spawner

setmetatable(Spawner, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Spawner:init(o)
    GameObject.init(self, o)

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
        self.size.w,
        self.size.h
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
    local enemy = Enemy({
        position = {
            x = self.position.x + self.size.w / 2,
            y = self.position.y + self.size.h / 2
        },
        parent = self,
    })
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
