---Shorthand method for creating quads based on a sprite.
---@param x number
---@param y number
---@param h number
---@param w number
---@param sprite Sprite
---@return love.Quad
function love.newQuad(x, y, h, w, sprite)
    return love.graphics.newQuad(x, y, h, w, sprite.image:getDimensions())
end
