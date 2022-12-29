--[[
    Implementation of timer. Usefull for actions that require time.
]]--

---@class Timer
---@overload fun(seconds?: number): Timer
local Timer = {}
Timer.__index = Timer

setmetatable(Timer, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

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
function Timer:seconds()
    return math.floor(self.deltaPassed)
end

---Checks whether a certain amount of time has passed.
---@param time number
function Timer:hasPassed(time)
    local remainder = self.deltaPassed % time
    --? Everything below 1 is fine.
    local flooredRemainder = math.floor(remainder)
    return flooredRemainder == 0
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
