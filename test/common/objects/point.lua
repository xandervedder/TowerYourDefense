require("test.setup")

local Point = require("src.common.objects.point")

local Lu = require("luaunit")

TestPoint = {}

function TestPoint:setUp()
    ---@type Point
    self.p1 = Point(1, 1)
    ---@type Point
    self.p1Equal = Point(1, 1)
    ---@type Point
    self.p2 = Point(2, 2)
end

function TestPoint:testShouldAddCorrectly()
    Lu.assertEquals(self.p1 + self.p2, Point(3, 3))
end

function TestPoint:testShouldSubtractCorrectly()
    Lu.assertEquals(self.p1 - self.p2, Point(-1, -1))
end

function TestPoint:testConcatShouldWorkCorrectlyAndNotThrow()
    local concatString = "abc"

    Lu.assertEquals(self.p1 .. concatString, "{ x=1, y=1 }abc")
end

function TestPoint:testShouldEqualWithTheSameValues()
    Lu.assertEquals(self.p1, self.p1Equal)
end

function TestPoint:testShouldNotEqualWithDifferingValues()
    Lu.assertNotEquals(self.p1, self.p2)
end

function TestPoint:testShouldFormatAsAStringCorrectly()
    Lu.assertEquals(tostring(self.p1), "{ x=1, y=1 }")
end
