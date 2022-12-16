local Damageable = require("src.game.object.damageable")
local Spawner = require("src.game.object.spawner")
local Constants = require("src.game.constants")
local Util = require("src.game.util.util")

local Point = require("src.common.objects.point")

-- TODO: location of import
local Size = require("src.gui.style.property.size")

--[[
    The mech that the player controls.
]]--

---@class Mech : Damageable
local Mech = {}
Mech.__index = Mech
Mech.MECH_PATH = "/assets/graphics/mech/mech.png"

setmetatable(Mech, {
    __index = Damageable,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor
---@param o any
---@param camera Camera
function Mech:init(o, camera)
    Damageable.init(self, o, 500)

    self.controls = {
        up = false,
        down = false,
        left = false,
        right = false,
    }
    ---@type Size
    self.size = Size(self.size.w / 2, self.size.h / 2)
    self.type = "Mech"

    ---@type Camera
    self.camera = camera
    ---@type Point
    self.untranslated = Point(0, 0)
    ---@type Point
    self.mouse = Point(0, 0)
    ---@type Point
    self.center = self:getMiddle()

    ---@type number
    self.shotSpeed = 5
    ---@type number
    self.shotDelta = 0;
    ---@type number
    self.shotDelay = 0.25
    self.shells = {}
    ---@type boolean
    self.mouseDown = false
    self.shellDamage = 20;

    self.mechSheet = self:createSheet(self.MECH_PATH)
    self.legsQuad = love.graphics.newQuad(Constants.tile.w * 2, 0, Constants.tile.w * 2, Constants.tile.h * 2, self.mechSheet:getDimensions())
    self.bodyQuad = love.graphics.newQuad(0, 0, Constants.tile.w * 2, Constants.tile.h * 2, self.mechSheet:getDimensions())
end

---Draw method.
function Mech:draw()
    Damageable.draw(self)

    self.center = self:getMiddle()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.mechSheet,
        self.legsQuad,
        self.center.x,
        self.center.y,
        self:getLegRotation(),
        Constants.scale / 2,
        Constants.scale / 2,
        (Constants.tile.w * 2) / 2,
        (Constants.tile.h * 2) / 2
    )

    love.graphics.draw(
        self.mechSheet,
        self.bodyQuad,
        self.center.x,
        self.center.y,
        self.rotation,
        Constants.scale / 2,
        Constants.scale / 2,
        -- Origin points will be in the center of the image:
        (Constants.tile.w * 2) / 2,
        (Constants.tile.h * 2) / 2
    )

    for _, shell in pairs(self.shells) do
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", shell.x, shell.y, 0.75 * Constants.scale * self.scale)
    end
end

---Gets the rotation of the legs.
---@return number
function Mech:getLegRotation()
    if self.controls.up then return math.rad(90) end
    if self.controls.down then return math.rad(-90) end
    if self.controls.right then return math.rad(180) end

    --? This is the default position:
    return math.rad(0)
end

---Update method.
---@param dt number
function Mech:update(dt)
    Damageable.update(self, dt)

    local camera = self.camera:getPoint()
    self.mouse = Point(math.abs(self.untranslated.x - camera.x), math.abs(self.untranslated.y - camera.y))
    self.rotation = self:rotateBodyToMousePoint()

    if self.controls.up then self.point.y = self.point.y - 2 end
    if self.controls.down then self.point.y = self.point.y + 2 end
    if self.controls.left then self.point.x = self.point.x - 2 end
    if self.controls.right then self.point.x = self.point.x + 2 end

    self:handleShells()
    self:handleTurrets(dt)
    self:handleCollision()
end

---Handles updating of the shells.
function Mech:handleShells()
    for _, shell in pairs(self.shells) do
        shell.x = shell.x + shell.velocity.x
        shell.y = shell.y + shell.velocity.y
    end
end

---Handles the shooting of both turrets.
---@param dt number
function Mech:handleTurrets(dt)
    if not self.mouseDown then return end

    self.shotDelta = self.shotDelta + dt
    if self.shotDelta >= self.shotDelay then
        table.insert(self.shells, self:shoot(6 * Constants.scale, math.rad(-90)))
        table.insert(self.shells, self:shoot(6 * Constants.scale, math.rad(90)))
        self.shotDelta = 0
    end
end

---Handles the collision of the shells.
function Mech:handleCollision()
    if #self.shells == 0 then return end

    local enemies = Spawner.getAllEnemies()
    for i = #self.shells, 1, -1 do
        local shell = self.shells[i]
        local x = shell.x
        local y = shell.y

        if (x > Constants.world.w or x < 0) or (y > Constants.world.h or y < 0) then -- Off screen
            table.remove(self.shells, i)
        else
            for _, enemy in pairs(enemies) do
                if Util.isWithin(shell, enemy) then
                    enemy:damage(self.shellDamage)
                    table.remove(self.shells, i)
                end
            end
        end
    end
end

---Gets the rotation of where the mech body should look at.
---@return number
function Mech:rotateBodyToMousePoint()
    local radians = math.atan2(self.center.y - self.mouse.y, self.center.x - self.mouse.x)
    if radians < 0 then
        radians = radians + (2 * math.pi)
    end

    return radians
end

---Key pressed event.
---@param key string
function Mech:keyPressed(key)
    self:keyProcessor(key, true)
end

---Key released event
---@param key string
function Mech:keyReleased(key)
    self:keyProcessor(key, false)
end

---Processes the key.
---@param key string
---@param on boolean
function Mech:keyProcessor(key, on)
    if key == "up" or key == "w" then self.controls.up = on end
    if key == "down" or key == "s" then self.controls.down = on end
    if key == "left" or key == "a" then self.controls.left = on end
    if key == "right" or key == "d" then self.controls.right = on end
    if key == "h" then self.controls.hide = on end
end

---Mouse moved event.
---@param x number
---@param y number
---@param dx number
---@param dy number
---@param touch boolean
function Mech:mouseMoved(x, y, dx, dy, touch)
    self.untranslated = Point(x, y)
end

---Mouse pressed event.
function Mech:mousePressed()
    self.mouseDown = true
end

function Mech:mouseReleased()
    self.mouseDown = false
end

---TODO: move this somewhere else
---Shoots from a certain configurable point.
---@param addition any
---@param radians any
---@return table
function Mech:shoot(addition, radians)
    local middlePointX = self.center.x + ((4 * Constants.scale) * -math.cos(self.rotation))
    local middlePointY = self.center.y + ((4 * Constants.scale) * -math.sin(self.rotation))

    local shell = {
        x = middlePointX + (addition * -math.cos(self.rotation + radians)),
        y = middlePointY + (addition * -math.sin(self.rotation + radians)),
        velocity = { x = 0, y = 0 },
        speed = self.shotSpeed,
    }
    shell.getPoint = function ()
        return { x = shell.x, y = shell.y }
    end

    -- https://stackoverflow.com/a/14857424
    -- TODO: this works now, it shoots with the barrel but it can still be improved...
    shell.velocity.x = -math.cos(self.rotation) * shell.speed
    shell.velocity.y = -math.sin(self.rotation) * shell.speed

    return shell
end

return Mech
