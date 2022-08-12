require("test.setup")

local Point = require("src.common.objects.point")

local Lu = require("luaunit")

TestPoint = {}

function TestPoint:testShouldAddCorrectly()
    local p1 = Point(1, 1)
    local p2 = Point(2, 2)

    Lu.assertEquals(Point(3, 3), p1 + p2)
end

function TestPoint:testShouldSubtractCorrectly()
    local p1 = Point(1, 1)
    local p2 = Point(2, 2)

    Lu.assertEquals(Point(-1, -1), p1 - p2)
end

function TestPoint:testConcatShouldWorkCorrectlyAndNotThrow()
    local p1 = Point(1, 1)
    local concatString = "abc"

    Lu.assertEquals(p1 .. concatString, "{ x=1, y=1 }abc")
end

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
