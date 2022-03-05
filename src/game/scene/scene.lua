-- TODO: Maybe have some other type of object with these base
-- methods and such:
local Scene = {}

function Scene:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.name = o.name or "unknown"
    return o
end

function Scene:initialize() end

function Scene:update(dt) end

function Scene:fixedUpdate(dt) end

function Scene:on(event) end

function Scene:draw(dt) end

function Scene:quit() end

function Scene:resize() end

function Scene:keyPressed(key) end

function Scene:keyReleased(key) end

function Scene:mouseMoved(x, y, dx, dy, touch) end

function Scene:mousePressed(x, y, button, touch, presses) end

function Scene:mouseReleased() end

function Scene:mouseWheelMoved() end

function Scene:getName()
    return self.name
end

function Scene:getCanvas()
    return self.canvas
end

return Scene
