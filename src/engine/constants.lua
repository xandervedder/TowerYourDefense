Constants = {}

Constants.tile = {
    height = 32,
    width = 32,
}

function Constants.tile.getDimensions()
    return Constants.tile.width, Constants.tile.height
end

-- Not sure if this is large enough, maybe this should be a configurable property
Constants.scale = 4

return Constants