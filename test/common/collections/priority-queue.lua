require("test.setup")

local PriorityQueue = require("src.common.collections.priority-queue")

local Lu = require("luaunit")

TestPriorityQueue = {}

function TestPriorityQueue:setUp()
    ---@type PriorityQueue
    self.queue = PriorityQueue()
end

function TestPriorityQueue:testShouldInitializeEmpty()
    Lu.assertTrue(self.queue:empty())
end

function TestPriorityQueue:testShouldNotBeEmptyAfterPushingItemInTheQueue()
    self.queue:push({ "test", 1 })

    Lu.assertFalse(self.queue:empty())
end

function TestPriorityQueue:testSizeShouldBeZeroWhenInitializing()
    Lu.assertEquals(self.queue:size(), 0)
end

function TestPriorityQueue:testShouldReturnCorrectSizeAfterPush()
    self.queue:push({ "test", 1 })

    Lu.assertEquals(self.queue:size(), 1)
end

function TestPriorityQueue:testShouldErrorWhenNoDataIsGiven()
    ---@diagnostic disable-next-line: missing-parameter
    Lu.assertErrorMsgContains("Data cannot be empty.", function() self.queue:push() end)
end

function TestPriorityQueue:testShouldErrorWhenWrongDataTypeIsGiven()
    ---@diagnostic disable-next-line: param-type-mismatch
    Lu.assertErrorMsgContains("Data must be of table type. Type 'number' given.", function() self.queue:push(1) end)
end

function TestPriorityQueue:testShouldErrorWhenMoreThanTwoItemsAreInTheTableGiven()
    Lu.assertErrorMsgContains(
        "Exactly 2 items must be in the table. Table contains '3'.",
        function () self.queue:push({ "", "", "" }) end
    )
end

function TestPriorityQueue:testShouldGiveCorrectPriorityItem()
    self.queue:push({ "a", 3 })
    self.queue:push({ "b", 2 })
    self.queue:push({ "c", 1 })

    Lu.assertEquals(self.queue:pop(), "c")
    Lu.assertEquals(self.queue:pop(), "b")
    Lu.assertEquals(self.queue:pop(), "a")
end

function TestPriorityQueue:testShouldGiveTheCorrectPriorityItemWithTheSamePriority()
    self.queue:push({ "a", 1 })
    self.queue:push({ "b", 1 })
    self.queue:push({ "c", 1 })
    self.queue:push({ "d", 2 })

    Lu.assertEquals(self.queue:pop(), "c")
end

function TestPriorityQueue:testShouldFormatAsAStringCorrectly()
    self.queue:push({ "a", 1 })
    self.queue:push({ "b", 1 })

    Lu.assertEquals(tostring(self.queue), "[{b, 1}, {a, 1}]")
end
