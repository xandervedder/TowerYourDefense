require("test.setup")

local NearestNeighbour = require("src.common.algorithms.nearest-neighbour")

local Point = require("src.common.objects.point")

local Lu = require("luaunit")

TestNearestNeighbour = {}


function TestNearestNeighbour:setUp()
    ---@type NearestNeighbour
    self.neighbour = NearestNeighbour({
        Point(0, 1),
        Point(1, 1),
        Point(1, 2),
        Point(2, 1),
        Point(2, 2),
        Point(3, 1),
        Point(3, 2),
    })
end

function TestNearestNeighbour:testShouldPowerUpCorrectlyWithTheSameValues()
    Lu.assertEquals(self.neighbour:toPower(Point(2, 2)), 8)
end

function TestNearestNeighbour:testShouldPowerUpCorrectlyWithDifferingValues()
    Lu.assertEquals(self.neighbour:toPower(Point(2, 1)), 5)
end

function TestNearestNeighbour:testShouldCalculateDistanceCorrectlyWithZero()
    Lu.assertEquals(self.neighbour:distance(0, Point(2, 1)), 5)
end

function TestNearestNeighbour:testShouldCalculateDistanceCorrectlyWithDifferingStartValue()
    Lu.assertEquals(self.neighbour:distance(1, Point(2, 1)), 4)
end

function TestNearestNeighbour:testShouldGetTheNearestNeighbour()
    Lu.assertEquals(self.neighbour:get(Point(0, 0)), Point(0, 1))
end
