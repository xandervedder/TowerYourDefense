--[[
    Implementation of timer. Usefull for actions that require time.
]]--

---@class Timer
---@overload fun(seconds: number): Timer
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
---@param seconds number
function Timer:init(seconds)
    ---@private
    ---@type integer
    self.targetSeconds = seconds
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

---Checks whether or not `x` amount of seconds have passed.
---@param seconds any
function Timer:hasPassed(seconds)
    local remainder = self.deltaPassed % seconds
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
