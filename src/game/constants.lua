local Constants = {}

-- Not sure if this is large enough, maybe this should be a configurable property
Constants.scale = 8
Constants.tile = {
    h = 16,
    w = 16,
}

function Constants.tile.scaledHeight()
    return Constants.tile.h * Constants.scale
end

function Constants.tile.scaledWidth()
    return Constants.tile.w * Constants.scale
end

function Constants.tile.getDimensions()
    return Constants.tile.w, Constants.tile.h
end

return Constants
