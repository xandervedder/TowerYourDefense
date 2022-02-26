Constants = {}

-- Not sure if this is large enough, maybe this should be a configurable property
Constants.scale = 8
Constants.tile = {
    height = 16,
    width = 16,
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
