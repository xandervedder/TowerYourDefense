local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")

--[[
    Implementation of the wave concept. A wave has control over how many enemies a Spawner should
    spawn. This amount will increase based on which wave it currently is.
]]--

---@class Wave
local Wave = {}
Wave.__index = Wave

setmetatable(Wave, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor of the wave concept.
---@param spawners Spawner[]
function Wave:init(spawners)
    ---@private
    ---@type boolean
    self.waiting = true
    ---@private
    ---@type boolean
    self.hasDoneStartUpProcedure = false
    ---@private
    ---@type integer
    self.countDown = 30
    ---@private
    ---@type number
    self.countDownDelta = 0
    ---@private
    ---@type integer
    self.currentWave = 1;
    ---@private
    ---@type Spawner[]
    self.spawners = spawners
    ---@private
    ---@type integer
    self.baseEnemySpawnCount = 10
    ---@private 
    ---@type number
    self.baseEnemyHealthAmount = 100
end

---Update method.
---@param dt number
function Wave:update(dt)
    if self.waiting then
        self:waitProcedure(dt)
        return
    end

    if not self.hasDoneStartUpProcedure then
        self:start()
        self.hasDoneStartUpProcedure = true
    end

    if self:waveComplete() then
        Publisher.publish(Event("wave.ended"))
        self:prepareNextWave()
    end
end

---@private
---A small timeout untill the waves begin.
---@param dt number
function Wave:waitProcedure(dt)
    self.countDownDelta = self.countDownDelta + dt
    if self.countDownDelta >= self.countDown then
        self.waiting = false
        self.countDownDelta = 0
    end
end

---@private
---Starts the wave
function Wave:start()
    local spawnAmount = self:nextEnemySpawnCount()
    local enemyHealth = self:nextEnemyHealthAmount()
    for _, spawner in pairs(self.spawners) do
        spawner:beginSpawning(spawnAmount, enemyHealth)
    end

    Publisher.publish(Event("wave.started", self.currentWave))
end

---Gets the enemy spawn count for the next wave.
---@return integer
function Wave:nextEnemySpawnCount()
    return self.baseEnemySpawnCount + ((self.baseEnemySpawnCount / 2) * (self.currentWave - 1))
end

---Gets the health amount that the enemies will have in the next wave.
---@return number
function Wave:nextEnemyHealthAmount()
    return self.baseEnemyHealthAmount + (10 * (self.currentWave - 1))
end

---@private
---Determines if the wave has been completed.
---@return boolean
function Wave:waveComplete()
    for _, spawner in pairs(self.spawners) do
        if not spawner:isDone() then
            return false
        end
    end

    return true
end

---@private
---Prepares the next wave.
function Wave:prepareNextWave()
    self.waiting = true
    self.hasDoneStartUpProcedure = false
    self.currentWave = self.currentWave + 1
end

return Wave
