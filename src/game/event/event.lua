local Event = {}

function Event:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.name = o.name or ""
    self.data = o.data or {}
    return o
end

function Event:getName()
    return self.name
end

function Event:getData()
    return self.data
end

return Event
