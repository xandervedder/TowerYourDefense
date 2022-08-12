require("test.setup")

local Lu = require("luaunit")

local Point = require("src.common.objects.point")

TestPoint = {}

function TestPoint:testShouldEqualWithTheSameValues()
    local p1 = Point(1, 1)
    local p2 = Point(1, 1)

    Lu.assertEquals(p1, p2)
end

function TestPoint:testShouldNotEqualWithDifferingValues()
    local p1 = Point(1, 1)
    local p2 = Point(0, 0)

    Lu.assertNotEquals(p1, p2)
end

function TestPoint:testShouldFormatAsAStringCorrectly()
    local p1 = Point(1, 1)

    Lu.assertEquals(tostring(p1), "{ x=1, y=1 }")
end

os.exit(Lu.LuaUnit.run())
