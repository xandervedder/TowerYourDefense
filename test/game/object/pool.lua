require("test.setup")

local Enemy = require("src.game.objects.enemy")
local GameObject = require("src.game.objects.game-object")
local Pool = require("src.game.objects.pool")

local Lu = require("luaunit")

TestPool = {}

function TestPool:setUp()
    ---@type Pool
    self.pool = Pool()
end

function TestPool:testShouldIncreaseSize()
    self.pool:add(GameObject({}))

    Lu.assertEquals(self.pool:size(), 1)
end

function TestPool:testShouldDeleteObjectCorrectly()
    local object = GameObject({})

    self.pool:add(object)
    Lu.assertEquals(#self.pool:get(), 1)

    self.pool:delete(object)
    Lu.assertEquals(#self.pool:get(), 0)
end

function TestPool:testShouldDeleteByPredicateCorrectly()
    self.pool:add(GameObject({}))
    self.pool:add(GameObject({}))
    self.pool:add(Enemy({}, {}, {}, {}, {}, {}, {}))

    self.pool:deleteBy(function(o) return o.type == "GameObject" end)

    Lu.assertEquals(#self.pool:get(), 1)
end

function TestPool:testShouldSoftDeleteAndRestoreCorrectly()
    local object = GameObject({})
    self.pool:add(object)

    self.pool:softDelete(object)
    ---@diagnostic disable-next-line: invisible (for testing purposes)
    Lu.assertEquals(#self.pool.softDeleted, 1)
    Lu.assertEquals(#self.pool:get(), 0)

    self.pool:restore()
    Lu.assertEquals(#self.pool:get(), 1)
end

function TestPool:testShouldSoftDeleteByPredicate()
    self.pool:add(GameObject({}))
    self.pool:add(GameObject({}))
    self.pool:add(GameObject({}))

    self.pool:softDeleteBy(function(o) return o.type == "GameObject" end)

    ---@diagnostic disable-next-line: invisible (for testing purposes)
    Lu.assertEquals(#self.pool.softDeleted, 3)
    Lu.assertEquals(#self.pool:get(), 0)
end

function TestPool:testShouldGetObjectByPredicate()
    self.pool:add(GameObject({}))
    self.pool:add(GameObject({}))
    self.pool:add(Enemy({}, {}, {}, {}, {}, {}, {}))

    Lu.assertEquals(#self.pool:getByType("Enemy"), 1)
    Lu.assertEquals(#self.pool:getByType("GameObject"), 2)
end
