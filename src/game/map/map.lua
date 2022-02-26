local Map = {}

function Map.read(asset)
    local rawData = love.filesystem.read(asset)
    local mapData = {}
    for i, value in pairs(Map.split(rawData, "\n")) do
        mapData[i] = {}
        for j, letter in pairs(Map.split(value, " "))do
            mapData[i][j] = letter
        end
    end

    return mapData
end

-- https://stackoverflow.com/a/7615129 (modified)
function Map.split(input, seperator)
    seperator = seperator or "%s"

    local matches = {}
    for str in string.gmatch(input, "([^" .. seperator .. "]+)") do
        table.insert(matches, str)
    end

    return matches
end

return Map
