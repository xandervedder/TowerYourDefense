local defineClass = require("src.common.objects.define-class")

---@class Scene
local Scene = defineClass()

function Scene:init(o)
    ---@protected
    self.name = o.name or "unknown"
end

---@protected
function Scene:_getCanvas()
    return love.graphics.newCanvas(love.graphics.getDimensions())
end

function Scene:update(dt) end

function Scene:fixedUpdate(dt) end

function Scene:on(event) end

function Scene:draw() end

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

return Scene
