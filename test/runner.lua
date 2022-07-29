--[[
    Simple test runner that runs every tests.

    For now, in a "hacky" way, untill I find a better solution.
]]--

function executeTest(location)
    os.execute("lua " .. location .. " --verbose")
end

local locations = {
    "test/common/objects/point.lua"
}

for _, location in pairs(locations) do
    executeTest(location)
end
