--[[
    Simple test runner that runs every tests. It does so by requiring every test into this file.
]]--

require("test.common.collections.priority-queue")
require("test.common.collections.queue")
require("test.common.objects.point")
require("test.setup")

local Lu = require("luaunit")

os.exit(Lu.LuaUnit.run())
