local Timer = require("src.common.time.timer")

--[[
    Makes it possible to 'animate' over a sprite sheet.
    This doesn't actually do the rendering, 
    but it allows the correct quad to be returned with the configured time.
]]--

---@class SpriteConfig
---@field quad love.Quad
---@field time number

---@class SpriteAnimator
local SpriteAnimator = {}
SpriteAnimator.__index = SpriteAnimator

setmetatable(SpriteAnimator, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor.
---@param defaultState love.Quad
---@param config SpriteConfig[]
function SpriteAnimator:init(defaultState, config)
    ---@private
    ---@type love.Quad
    self.defaultState = defaultState
    ---@private
    ---@type SpriteConfig[]
    self.config = config
    ---@private
    ---@type integer
    self.configIndex = 1
    ---@private
    ---@type Timer
    self.timer = Timer()
    ---@private
    ---@type boolean
    self.isPaused = false
end

---Update method of the SpriteAnimator.
---@param dt number
function SpriteAnimator:update(dt)
    if self.isPaused then return end

    self.timer:update(dt)

    local spriteConfig = self.config[self.configIndex]
    if self.timer:hasPassedExact(spriteConfig.time) then
        self:handleQuadChange()
    end
end

---Changes the index of the config to be equal to the quad that should be drawn.
function SpriteAnimator:handleQuadChange()
    self.configIndex = self.configIndex + 1
    if self.configIndex > #self.config then
        self.configIndex = 1
    end

    self.timer:reset()
end

---Returns the quad that is currently active
---@return love.Quad
function SpriteAnimator:activeQuad()
    if self.isPaused then return self.defaultState end

    return self.config[self.configIndex].quad
end

---Resets the SpriteAnimator to its default state.
function SpriteAnimator:reset()
    self.configIndex = 1
end

---Pauses the animator.
function SpriteAnimator:pause()
    self.isPaused = true
end

---Resumes the animator.
function SpriteAnimator:resume()
    self.isPaused = false
end

return SpriteAnimator
