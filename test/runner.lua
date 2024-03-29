--[[
    Simple test runner that runs every tests. It does so by requiring every test into this file.
]]--

require("test.common.algorithms.a-star")
require("test.common.algorithms.nearest-neighbour")
require("test.common.algorithms.weighted-graph")
require("test.common.collections.priority-queue")
require("test.common.collections.queue")
require("test.common.objects.define-class")
require("test.common.objects.point")
require("test.common.time.timer")
require("test.game.objects.game-object")
require("test.game.objects.pool")
require("test.gui.element")
require("test.setup")

local Lu = require("luaunit")

os.exit(Lu.LuaUnit.run())
