local defineClass = require("src.common.objects.define-class")
local Point = require("src.common.objects.point")

local C = require("src.game.constants")
local Util = require("src.game.util.util")

---@class MegaTowerTool
local MegaTowerTool = defineClass()

function MegaTowerTool:init(o)
    ---@private
    ---@type Pool
    self.pool = o.pool
    ---@private
    ---@type Camera
    self.camera = o.camera
    ---@private
    ---@type Point
    self.mouse = Point(0, 0)
    ---@private
    ---@type number
    self.lineWidth = C.scale
    ---@private
    ---@type boolean
    self.active = false
    ---@private
    ---@type boolean
    self.filled = false
    ---@private
    ---@type Tower
    self.tower = nil
end

function MegaTowerTool:draw()
    if not self.active then return end

    local grid = Util.fromMousePoint(self.mouse.x, self.mouse.y)
    local size = Util.size(1)

    if self.filled then
        love.graphics.setColor(0, 1, 0, 0.75)
    else
        love.graphics.setColor(1, 0, 0, 0.75)
    end

    love.graphics.setLineWidth(self.lineWidth)
    --? Note: "rough" is better than smooth for just normal rectangles in my case.
    love.graphics.setLineStyle("rough")
    love.graphics.rectangle(
        "line",
        grid.x + self.lineWidth / 2,
        grid.y + self.lineWidth / 2,
        (size.w * 2) - self.lineWidth,
        (size.h * 2) - self.lineWidth
    )
end

function MegaTowerTool:update()
    if not self.active then return end

    ---@private
    self.occupied = {
        ---@type GameObject
        tl = nil, -- Top left
        ---@type GameObject
        tr = nil, -- Top right
        ---@type GameObject
        bl = nil, -- Bottom left
        ---@type GameObject
        br = nil, -- Bottom right
    }

    local grid = Util.fromMousePoint(self.mouse.x, self.mouse.y)
    local size = Util.size(1)
    for _, gameObject in pairs(self.pool:get()) do
        local p = gameObject:getPoint()
        if p.x == grid.x and p.y == grid.y then self.occupied.tl = gameObject end
        if p.x == grid.x + size.w and p.y == grid.y then self.occupied.tr = gameObject end
        if p.x == grid.x and p.y == grid.y + size.w then self.occupied.bl = gameObject end
        if p.x == grid.x + size.w and p.y == grid.y + size.w then self.occupied.br = gameObject end
    end

    if (self.occupied.tl and
        self.occupied.tr and
        self.occupied.bl and
        self.occupied.br and
        self:checkForTowers(self.occupied)
    ) then
        ---@type GameObject
        self.tower = self.occupied.tl
        self.filled = true
    else
        self.filled = false
    end

    self.mouse = self.camera:mousePosition()
end

---Checks if the gameobjects in the self.occupied space are Towers.
---@param occupiedSpots table<string, Tower>
---@return boolean
function MegaTowerTool:checkForTowers(occupiedSpots)
    if (occupiedSpots.tr.type ~= "Tower" or
        occupiedSpots.tl.type ~= "Tower" or
        occupiedSpots.bl.type ~= "Tower" or
        occupiedSpots.br.type ~= "Tower")
    then
        return false
    end

    ---@type string
    local type = occupiedSpots.tr.turret.type
    return (
        occupiedSpots.tl.turret.type == type and
        occupiedSpots.bl.turret.type == type and
        occupiedSpots.br.turret.type == type
    )
end

function MegaTowerTool:mousePressed(_, _, _, _, _)
    if not self.filled then return end

    self.tower.turret:setSize(2)
    self.tower.turret:setScale(2)
    --TODO: setters (protected access)
    self.tower.turret.range = self.tower.turret.range * 2
    self.tower.turret.damage = self.tower.turret.damage * 5
    self.tower.turret.firingDelay = self.tower.turret.firingDelay * 4
    self.tower.base.scale = 2

    self.pool:deleteBy(function(o)
        for _, tower in pairs({ self.occupied.tr, self.occupied.bl, self.occupied.br }) do
            if tower == o then return true end
        end

        return false
    end)
end

---Toggles the state of the tool.
function MegaTowerTool:toggle()
    self.active = not self.active
end

return MegaTowerTool
