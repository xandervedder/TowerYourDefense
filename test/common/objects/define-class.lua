require("test.setup")

local defineClass = require("src.common.objects.define-class")

local Lu = require("luaunit")

--- Test classes

local Super = defineClass()

function Super:init(test)
    self.t = test
end

function Super:setT(val)
    self.t = val
end

local SubClass = defineClass(Super)

function SubClass:init(test)
    Super.init(self, test)
    self.testValue = test
end

local SubSubClass = defineClass(SubClass)

function SubSubClass:init(test)
    SubClass.init(self, test)
end

--- End test classes

TestDefineClass = {}

function TestDefineClass:setUp()
    self.class1 = SubSubClass(false)
    self.class2 = SubSubClass(true)
end

function TestDefineClass:testShouldNotHaveChangedValue()
    --? I had some issues before, where super instances would share
    --? the same instance. This is a leftover from when that happened.
    Lu.assertFalse(self.class1.t)
    Lu.assertTrue(self.class2.t)
end

function TestDefineClass:testShouldChangeValue()
    self.class1:setT(true)
    self.class2:setT(false)

    Lu.assertTrue(self.class1.t)
    Lu.assertFalse(self.class2.t)
end
