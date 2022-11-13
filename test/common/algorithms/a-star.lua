require("test.setup")

local AStar = require("src.common.algorithms.a-star")
local WeightedGraph = require("src.common.algorithms.weighted-graph")
local Point = require("src.common.objects.point")

local Lu = require("luaunit")

TestAStar = {}

function TestAStar:setUp()
    ---@type AStar
    self.aStar = AStar(WeightedGraph(5, 5), Point(0, 0), Point(5, 5))
end

function TestAStar:testShouldNotBeSearchableWhenSurroundedByAllSides()
    ---@type AStar
    local aStar = AStar(
        WeightedGraph(
            5,
            5,
            {
                Point(4, 3),
                Point(3, 4),
                Point(2, 3),
                Point(3, 2),
            }),
        Point(0, 0),
        Point(3, 3))

    Lu.assertFalse(aStar:isSearchable())
end

function TestAStar:testShouldBeSearchableWhenNotSurrounded()
    Lu.assertIsTrue(self.aStar:isSearchable())
end

function TestAStar:testHashingMethod()
    Lu.assertEquals(self.aStar:toHash(Point(0, 0)), "0,0")
end

function TestAStar:testHeuristic()
    Lu.assertEquals(self.aStar:heuristic(Point(0, 0), Point(1, 1)), 2)
end

function TestAStar:testShouldHaveTheCorrectEndGoal()
    local path = self.aStar:search():reconstructPath():get()

    Lu.assertEquals(path[#path], Point(5, 5))
end

function TestAStar:testShouldHaveTheCorrectPathCount()
    local path = self.aStar:search():reconstructPath():get()

    Lu.assertEquals(#path, 11)
end

function TestAStar:testShouldHaveCorrectPathCountWithObstacle()
    self.aStar.graph.obstacles = {
        Point(2, 3),
        Point(2, 2),
        Point(2, 1),
        Point(2, 0),
    }
    local path = self.aStar:search():reconstructPath():get()

    Lu.assertEquals(#path, 11)
end
