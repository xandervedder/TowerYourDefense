local C = require("src.game.constants")
local Turret = require("src.game.object.tower.turret.turret")

---@class SingleBarrelTurret : Turret
local SingleBarrelTurret = {}
SingleBarrelTurret.__index = SingleBarrelTurret

setmetatable(SingleBarrelTurret, {
    __index = Turret,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function SingleBarrelTurret:init(o)
    -- q is Quad in this instance
    o.q = { x = 0, y = 0 }
    o.location = "assets/graphics/turret-spritesheet.png"

    Turret.init(self, o)

    self.type = "SingleBarrelTurret"
end

function SingleBarrelTurret:update(dt)
    Turret.update(self, dt)

    if self.enemy == nil then return end

    self.elapsedTime = self.elapsedTime + dt
    if not (self.elapsedTime >= self.firingDelay) then return end
    self.elapsedTime = 0

    if self:withinRange(self.enemy) and not self.enemy:isDead() and self:isAimedAtEnemy() then
        self:shoot()
    end
end

---Shoots any shell type.
function SingleBarrelTurret:shoot()
    -- TODO: shell should be its own object in a different file
    local shell = {
        -- https://math.stackexchange.com/a/3534251
        x = self.center.x + ((8 * C.scale * self.scale) * -math.cos(self.rotation)),
        y = self.center.y + ((8 * C.scale * self.scale) * -math.sin(self.rotation)),
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

    table.insert(self.activeShells, shell)
end

return SingleBarrelTurret
