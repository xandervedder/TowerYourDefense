require("test.setup")

local NearestNeighbour = require("src.common.algorithms.nearest-neighbour")

local Point = require("src.common.objects.point")

local Lu = require("luaunit")

TestNearestNeighbour = {}


function TestNearestNeighbour:setUp()
    ---@type NearestNeighbour
    self.neighbour = NearestNeighbour({
        Point(1, 2),
        Point(2, 1),
        Point(2, 2),
        Point(3, 1),
        Point(3, 2),
    })
end

function TestNearestNeighbour:testShouldCalculateDistanceCorrectlyWithZero()
    Lu.assertEquals(math.floor(self.neighbour:distance(Point(0, 0), Point(2, 1))), 2)
end

function TestNearestNeighbour:testShouldCalculateDistanceCorrectlyWithDifferingStartValue()
    Lu.assertEquals(math.floor(self.neighbour:distance(Point(1, 0), Point(2, 1))), 1)
end

function TestNearestNeighbour:testShouldGetTheNearestNeighbourWithOneValue()
    self.neighbour = NearestNeighbour({ Point(0, 1)})
    Lu.assertEquals(self.neighbour:get(Point(0, 0)), Point(0, 1))
end

function TestNearestNeighbour:testShouldGetTheNearestNeighbourWithMultipleValues()
    Lu.assertEquals(self.neighbour:get(Point(0, 0)), Point(1, 2))
end

function TestNearestNeighbour:testShouldGetTheNearestNeighbourWithDifferentStartPoint()
    Lu.assertEquals(self.neighbour:get(Point(2, 3)), Point(2, 2))
end
