local C = require("src.game.constants")
local Turret = require("src.game.object.tower.turret.turret")

--! Note: quickly made this one is just for fun, code could be duplicated less...

---@class TripleBarrelTurret : Turret
local TripleBarrelTurret = {}
TripleBarrelTurret.__index = TripleBarrelTurret
TripleBarrelTurret.LEFT = 2 * C.scale
TripleBarrelTurret.RIGHT = 2 * C.scale

setmetatable(TripleBarrelTurret, {
    __index = Turret,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function TripleBarrelTurret:init(o)
    o.q = { x = 32, y = 0 }
    o.location = "assets/graphics/turret-spritesheet.png"

    Turret.init(self, o)
end

function TripleBarrelTurret:update(dt)
    Turret.update(self, dt)

    if self.enemy == nil then return end

    self.elapsedTime = self.elapsedTime + dt
    if not (self.elapsedTime >= self.firingDelay) then return end
    self.elapsedTime = 0

    if self:withinRange(self.enemy) and not self.enemy:isDead() then
        self:shoot()
    end
end

function TripleBarrelTurret:shoot()
    -- TODO: shell should be its own object in a different file
    local leftBarrelShell = self:configureShell(self.LEFT, math.rad(-90))
    local middleBarrelShell = self:configureShell(0, 0)
    local rightBarrelShell = self:configureShell(self.RIGHT, math.rad(90))

    table.insert(self.activeShells, leftBarrelShell)
    table.insert(self.activeShells, middleBarrelShell)
    table.insert(self.activeShells, rightBarrelShell)
end

function TripleBarrelTurret:configureShell(addition, radians)
    local middlePointX = self.center.x + ((8 * C.scale) * -math.cos(self.rotation))
    local middlePointY = self.center.y + ((8 * C.scale) * -math.sin(self.rotation))

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

return TripleBarrelTurret