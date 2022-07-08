---@class Location
local Location = {}
Location.__index = Location

setmetatable(Location, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor
---@param x number
---@param y number
function Location:init(x, y)
    self.x = x
    self.y = y
end

---@param toCompare Location
function Location:__eq(toCompare)
    return self.x == toCompare.x and self.y == toCompare.y
end

function Location:__tostring()
    return "{ x=" .. self.x .. ", y=" .. self.y .. " }"
end

return Location
