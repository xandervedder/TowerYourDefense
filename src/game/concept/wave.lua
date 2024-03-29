local defineClass = require("src.common.objects.define-class")
local Timer = require("src.common.time.timer")

local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")

--[[
    Implementation of the wave concept. A wave has control over how many enemies a Spawner should
    spawn. This amount will increase based on which wave it currently is.
]]--

---@class Wave
local Wave = defineClass()

---Constructor of the wave concept.
---@param spawners Spawner[]
function Wave:init(spawners)
    ---@private
    ---@type boolean
    self.hasDoneStartUpProcedure = false
    ---@private
    ---@type integer
    self.waitPeriod = 30
    ---@private
    ---@type boolean
    self.waiting = true
    ---@private
    ---@type Timer
    self.timer = Timer(self.waitPeriod)
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
    self.timer:update(dt)

    if self.timer:hasPassed(1) and self.waiting then
        Publisher.publish(Event("wave.countdown", self.waitPeriod - self.timer:seconds()))
    end

    if not self.timer:hasPassedTargetSeconds() then return end

    self.waiting = false
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
    self.hasDoneStartUpProcedure = false
    self.currentWave = self.currentWave + 1
    self.timer:reset()
    self.waiting = true
end

return Wave
