require("test.setup")

local Timer = require("src.common.time.timer")

local Lu = require("luaunit")

TestTimer = {}

function TestTimer:setup()
    self.timer = Timer(10)
end

function TestTimer:testTargetTimeHasPassed()
    self.timer:update(10)
    Lu.assertTrue(self.timer:hasPassedTargetSeconds())
end

function TestTimer:testSecondsHavePassed()
    self.timer:update(2)
    Lu.assertTrue(self.timer:hasPassed(2))
end

function TestTimer:testConsecutiveSecondsHavePassed()
    self.timer:update(4)
    Lu.assertTrue(self.timer:hasPassed(2))
    Lu.assertTrue(self.timer:hasPassed(4))

    self.timer:update(1)
    Lu.assertFalse(self.timer:hasPassed(2))
end

function TestTimer:testSecondsHavePassedWithIrregularDelta()
    self.timer:update(0.5)
    self.timer:update(0.75)
    self.timer:update(1.33)
    Lu.assertTrue(self.timer:hasPassed(2))
end

function TestTimer:testSecondsGetterWithWholeNumber()
    self.timer:update(1)

    Lu.assertEquals(self.timer:seconds(), 1)
end

function TestTimer:testSecondsGetterWithFloatNumber()
    self.timer:update(1.2)

    Lu.assertEquals(self.timer:seconds(), 1)
end

function TestTimer:testSecondsGetterWithZero()
    Lu.assertEquals(self.timer:seconds(), 0)
end

function TestTimer:testSecondsHavePassedWithIrregularNumbers()
    self.timer:update(0.5)
    Lu.assertTrue(self.timer:hasPassed(0.5))
end
