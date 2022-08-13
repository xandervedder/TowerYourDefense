require("test.setup")

local Point = require("src.common.objects.point")
local WeightedGraph = require("src.common.algorithms.weighted-graph")

local Lu = require("luaunit")

TestWeightedGraph = {}

function TestWeightedGraph:setUp()
    ---@type WeightedGraph
    self.graph = WeightedGraph(10, 10)
    self.graph.obstacles = { Point(2, 2) }
end

function TestWeightedGraph:testCostShouldBeOne()
    ---@diagnostic disable-next-line: missing-parameter
    Lu.assertEquals(self.graph:cost(), 1)
end

function TestWeightedGraph:testPointShouldBeInBounds()
    Lu.assertTrue(self.graph:inBounds(Point(1, 1)))
    Lu.assertTrue(self.graph:inBounds(Point(10, 10)))
end

function TestWeightedGraph:testPointShouldNotBeInBounds()
    Lu.assertFalse(self.graph:inBounds(Point(11, 10)))
end

function TestWeightedGraph:testPointShouldBeObstructed()
    Lu.assertTrue(self.graph:obstructed(Point(2, 2)))
end

function  TestWeightedGraph:testPointShouldNotBeObstructed()
    Lu.assertFalse(self.graph:obstructed(Point(1, 1)))
end

function TestWeightedGraph:testTheRightAmountOfNeighboursShouldBeReturnedWithNoObstructions()
    Lu.assertEquals(#self.graph:neighbours(Point(4, 4)), 4)
end

function TestWeightedGraph:testTheRightAmountOfNeighboursShouldBeReturnedWithObstruction()
    Lu.assertEquals(#self.graph:neighbours(Point(2, 1)), 3)
end

function TestWeightedGraph:testTheRightAmountOfNeighboursShouldBeReturnedWithNotInBounds()
    Lu.assertEquals(#self.graph:neighbours(Point(0, 0)), 2)
end
