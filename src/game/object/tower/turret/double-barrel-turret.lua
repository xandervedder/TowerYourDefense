local Turret = require("src.game.object.tower.turret.turret")

---@class DoubleBarrelTurret : Turret
local DoubleBarrelTurret = {}
DoubleBarrelTurret.__index = DoubleBarrelTurret
DoubleBarrelTurret.LEFT = 18
DoubleBarrelTurret.RIGHT = 18

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
    local leftBarrelShell = self:configureShell(self.center.x - self.LEFT, self.center.y)
    local rightBarrelShell = self:configureShell(self.center.x + self.RIGHT, self.center.y)

    table.insert(self.activeShells, leftBarrelShell)
    table.insert(self.activeShells, rightBarrelShell)
end

function DoubleBarrelTurret:configureShell(x, y)
    -- TODO: shoot from tip of barrel
    local shell = {
        x = x,
        y = y,
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

return DoubleBarrelTurret
