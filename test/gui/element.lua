require("test.mocks.love")
require("test.setup")

local Point = require("src.common.objects.point")
local Style = require("src.gui.style.style")
local Size = require("src.gui.style.property.size")
local Element = require("src.gui.element")

local Lu = require("luaunit")

TestElement = {}

function TestElement:setUp()
    ---@type Element
    self.element = Element({
        root = true,
        id = "a",
        children = { Element({ id = "b" }) },
        style =  Style({
            size = Size(100, 100),
            position = Point(0, 0)
        }),
    })
end

function TestElement:testShouldBeRootWhenMarkedAsSuch()
    Lu.assertTrue(self.element:isRoot())
end

function TestElement:testQuerySelectorShouldFindItselfWhenIdIsEquivalent()
    Lu.assertEquals(self.element, self.element:querySelector("a"))
end

function TestElement:testQuerySelectorShouldFindChildInsteadOfItself()
    local element = self.element:querySelector("b")

    Lu.assertNotNil(element)
    Lu.assertNotEquals(self.element, element)
end

function TestElement:testQuerySelectorShouldReturnNilWhenIdDoesNotMatch()
    Lu.assertNil(self.element:querySelector("bogus"))
end

function TestElement:testElementShouldKnowThatAMouseHasEnteredIt()
    self.element:mouseMoved(10, 10, 0, 0, false)

    Lu.assertTrue(self.element.mouseEntered)
end

function TestElement:testElementShouldKnowThatAMouseHasNotEnteredIt()
    Lu.assertFalse(self.element.mouseEntered)
end

function TestElement:testElementShouldKnowThatAMouseHasEnteredAndLeftIt()
    self.element:mouseMoved(10, 10, 0, 0, false)

    Lu.assertTrue(self.element.mouseEntered)

    self.element:mouseMoved(200, 200, 0, 0, false)

    Lu.assertFalse(self.element.mouseEntered)
end

function TestElement:testElementShouldFireClickEventWhenMouseWasClickedInElement()
    local clicked = false
    self.element:addEventListener( "click", function() clicked = true end)
    self.element:mousePressed(10, 10, "", "", 1)

    Lu.assertTrue(clicked)
end

function TestElement:testElementShouldFireMouseEnterEventWhenMouseMovesInElement()
    local entered = false
    self.element:addEventListener("mouseenter", function() entered = true end)
    self.element:mouseMoved(10, 10, 0, 0, false)

    Lu.assertTrue(entered)
end

function TestElement:testElementShouldFireMouseOutEventAfterMouseLeavesElement()
    local left = false
    self.element:addEventListener("mouseout", function() left = true end)
    self.element:mouseMoved(10, 10, 0, 0, false)
    self.element:mouseMoved(200, 200, 0, 0, false)

    Lu.assertTrue(left)
end

function TestElement:testElementShouldFireMouseMoveEventWhenMouseMovesInElement()
    local moved = false
    self.element:addEventListener("mousemove", function() moved = true end)
    self.element:mouseMoved(10, 10, 0, 0, false)

    Lu.assertTrue(moved)
end

function TestElement:testElementShouldFireMouseReleasedEventWhenMouseIsReleasedInElement()
    local released = false
    self.element:addEventListener("mousereleased", function() released = true end)
    self.element:mouseReleased()

    Lu.assertTrue(released)
end

function TestElement:testElementShouldErrorWhenChildIsMarkedAsRoot()
    Lu.assertErrorMsgContains(
        "Child can't be root.",
        function()
            Element({
                children = {
                    Element({ root = true })
                }
            })
        end
    )
end
