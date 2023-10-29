local defineClass = require("src.common.objects.define-class")

--[[
    Implementation of timer. Usefull for actions that require time.
]]--

---@class Timer
local Timer = defineClass()

---Constructor.
---@param seconds? number
function Timer:init(seconds)
    ---@private
    ---@type integer
    self.targetSeconds = seconds or 0
    ---@private
    ---@type number
    self.deltaPassed = 0
end

---Timer update method.
---@param dt number
function Timer:update(dt)
    self.deltaPassed = self.deltaPassed + dt
end

---Gets the amount of seconds that have passed since starting the timer.
---@return number
function Timer:seconds()
    return math.floor(self.deltaPassed)
end

---Checks whether a certain amount of time has passed.
---@param time number
---@return boolean
function Timer:hasPassed(time)
    local remainder = self.deltaPassed % time
    --? Everything below 1 is fine.
    local flooredRemainder = math.floor(remainder)
    return flooredRemainder == 0
end

---Checks whether or not the delta has passed the amount given.
---@param time number
---@return boolean
function Timer:hasPassedExact(time)
    return self.deltaPassed >= time
end

---Returns whether the specified amount of seconds have passed.
---@return boolean
function Timer:hasPassedTargetSeconds()
    return self.deltaPassed >= self.targetSeconds
end

---Resets the timer.
function Timer:reset()
    self.deltaPassed = 0
end

return Timer
