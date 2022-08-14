require("test.setup")

local Queue = require("src.common.collections.queue")

local Lu = require("luaunit")

TestQueue = {}

function TestQueue:setUp()
    ---@type Queue
    self.queue = Queue()
end

function TestQueue:testShouldBeEmptyWithEmptyInitialization()
    Lu.assertTrue(self.queue:empty())
end

function TestQueue:testShouldNotBeEmptyAfterPushingItemInTheQueue()
    self.queue:push(1)

    Lu.assertFalse(self.queue:empty())
end

function TestQueue:testShouldNotBeEmptyAfterPushingTwoInTheQueueAndPoppingOne()
    self.queue:push(1)
    self.queue:push(2)
    local _ = self.queue:pop()

    Lu.assertFalse(self.queue:empty())
end

function TestQueue:testShouldRecieveNilWhenPoppingAnEmptyQueue()
    Lu.assertNil(self.queue:pop())
end

function TestQueue:testShouldRecieveSameItemAfterPushingAndPopping()
    self.queue:push(1)

    Lu.assertEquals(self.queue:pop(), 1)
end
