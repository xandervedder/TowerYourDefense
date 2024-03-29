local Constants = {}
Constants.physics = {}
Constants.physics.rate = 60
Constants.physics.timing = 1 / Constants.physics.rate
-- Not sure if this is large enough, maybe this should be a configurable property
Constants.scale = 8
Constants.tile = {
    h = 16,
    w = 16,
}
-- Not really a constant now, now is it?
Constants.world = {
    h = 0,
    w = 0,
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
