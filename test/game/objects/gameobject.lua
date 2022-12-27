require("test.setup")

local Point = require("src.common.objects.point")

local GameObject = require("src.game.objects.game-object")
local C = require("src.game.constants")

local Lu = require("luaunit")

TestGameObject = {}

function TestGameObject:setUp()
    ---@type GameObject
    self.object = GameObject({
        obstructionRange = 1,
        -- In a GameObject, its point here is *not* a GridPoint.
        point = Point(C.tile.scaledWidth(), C.tile.scaledHeight()),
    })
end

function TestGameObject:testShouldBeTrueWhenPointIsTheSameAsObjectsPoint()
    Lu.assertTrue(self.object:isWithinObstructionRange(Point(1, 1)))
end

function TestGameObject:testShouldBeTrueWhenPointIsWithinObjectsObstructionRange()
    ---@type Point[]
    local pointsToCheck = {
        Point(0, 0),
        Point(0, 1),
        Point(0, 2),
        Point(1, 0),
        Point(1, 2),
        Point(2, 0),
        Point(2, 1),
        Point(2, 2),
    }

    for _, point in pairs(pointsToCheck) do
        Lu.assertTrue(self.object:isWithinObstructionRange(point))
    end
end

function TestGameObject:testShouldBeFalseWhenObjectDoesNotHaveObstructionRange()
    self.object.obstructionRange = 0;

    Lu.assertFalse(self.object:isWithinObstructionRange(Point(0, 0)))
end

function TestGameObject:testShouldBeInRangeWhenRangeIsLarger()
    self.object.obstructionRange = 2

    Lu.assertTrue(self.object:isWithinObstructionRange(Point(-1, -1)))
end
