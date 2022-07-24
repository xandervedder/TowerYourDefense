-- TODO: A Test Runner would be very nice
package.path = "lua_modules/share/lua/5.4/?.lua;lua_modules/share/lua/5.4/?/init.lua;" .. package.path
package.cpath = "lua_modules/lib/lua/5.4/?.so;" .. package.cpath

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
