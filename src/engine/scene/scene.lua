Scene = {}

function Scene:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.name = o.name or "unknown"
    return o
end

-- TODO: Would be nice to have a mixin that has all these boilerplate methods

function Scene:initialize() end

function Scene:update(dt) end

function Scene:draw(dt) end

function Scene:quit() end

function Scene:resize() end

function Scene:keyPressed(key) end

function Scene:keyReleased(key) end

function Scene:mouseMoved() end

function Scene:mousePressed() end

function Scene:mouseReleased() end

function Scene:mouseWheelMoved() end

function Scene:getName()
    return self.name
end

return Scene
