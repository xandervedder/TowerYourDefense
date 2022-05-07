local C = require("src.game.constants")
local Turret = require("src.game.object.tower.turret.turret")

---@class DoubleBarrelTurret : Turret
local DoubleBarrelTurret = {}
DoubleBarrelTurret.__index = DoubleBarrelTurret

setmetatable(DoubleBarrelTurret, {
    __index = Turret,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function DoubleBarrelTurret:init(o)
    o.q = { x = 16, y = 0 }
    o.location = "assets/graphics/turret-spritesheet.png"

    Turret.init(self, o)

    self.type = "DoubleBarrelTurret"
    self.left = 2 * C.scale * self.scale
    self.right = 2 * C.scale * self.scale
end

function DoubleBarrelTurret:update(dt)
    Turret.update(self, dt)

    if self.enemy == nil then return end

    self.elapsedTime = self.elapsedTime + dt
    if not (self.elapsedTime >= self.firingDelay) then return end
    self.elapsedTime = 0

    if self:withinRange(self.enemy) and not self.enemy:isDead() then
        self:shoot()
    end
end

function DoubleBarrelTurret:shoot()
    -- TODO: shell should be its own object in a different file
    local leftBarrelShell = self:configureShell(self.left, math.rad(-90))
    local rightBarrelShell = self:configureShell(self.right, math.rad(90))

    table.insert(self.activeShells, leftBarrelShell)
    table.insert(self.activeShells, rightBarrelShell)
end

function DoubleBarrelTurret:configureShell(addition, radians)
    local middlePointX = self.center.x + ((8 * C.scale * self.scale) * -math.cos(self.rotation))
    local middlePointY = self.center.y + ((8 * C.scale * self.scale) * -math.sin(self.rotation))

    local shell = {
        x = middlePointX + (addition * -math.cos(self.rotation + radians)),
        y = middlePointY + (addition * -math.sin(self.rotation + radians)),
        velocity = { x = 0, y = 0 },
        speed = self.shotSpeed,
    }
    shell.getPosition = function ()
        return { x = shell.x, y = shell.y }
    end

    -- https://stackoverflow.com/a/14857424
    -- TODO: this works now, it shoots with the barrel but it can still be improved...
    shell.velocity.x = -math.cos(self.rotation) * shell.speed
    shell.velocity.y = -math.sin(self.rotation) * shell.speed

    return shell
end


function DoubleBarrelTurret:setScale(scaleFactor)
    Turret.setScale(self, scaleFactor)

    self.left = 2 * C.scale * self.scale
    self.right = 2 * C.scale * self.scale
end

return DoubleBarrelTurret
