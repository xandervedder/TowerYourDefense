local Player = require("src.engine.object.player")

Engine = {}

function Engine.configure(t)
    t.window.title = "Tower Your Defense"
    Engine.player = Player:new({ name="Xander" })
end

function Engine.load()
    Engine.player.getName()
end

function Engine.draw()
    
end

function Engine.update(dt)

end

function resize()

end

function Engine.quit()

end

function Engine.keyPressed()

end

function Engine.keyReleased()

end

function Engine.mouseMoved()

end

function Engine.mousePressed()

end

function Engine.mouseReleased()

end

function Engine.mouseWheelMoved()

end

return Engine
