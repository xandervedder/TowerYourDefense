Constants = {}

-- Not sure if this is large enough, maybe this should be a configurable property
Constants.scale = 4

Constants.tile = {
    height = 32,
    width = 32,
}

function Constants.tile.scaledHeight()
    return Constants.tile.height * Constants.scale
end

function Constants.tile.scaledWidth()
    return Constants.tile.width * Constants.scale
end

function Constants.tile.getDimensions()
    return Constants.tile.width, Constants.tile.height
end

return Constants
