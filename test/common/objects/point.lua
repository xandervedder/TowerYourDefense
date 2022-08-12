require("test.setup")

local Lu = require("luaunit")

local Point = require("src.common.objects.point")

TestPoint = {}

function TestPoint:testShouldEqualWithTheSameValues()
    local p1 = Point(1, 1)
    local p2 = Point(1, 1)

    Lu.assertEquals(p1, p2)
end

function TestPoint:testShouldFail()
    Lu.assertIsFalse(true)
end

os.exit(Lu.LuaUnit.run())
