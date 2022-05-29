-- This may be a bad idea according to the following article:
-- https://leafo.net/guides/customizing-the-luarocks-tree.html#quick-guide
-- However, I feel like this shouldn't be an issue since LÖVE will pack everything
-- in a single executable anyway.
package.path = "lua_modules/share/lua/5.4/?.lua;lua_modules/share/lua/5.4/?/init.lua;" .. package.path
package.cpath = "lua_modules/lib/lua/5.4/?.so;" .. package.cpath

local Game = require("src.game.game")

function love.conf(t)
    Game.configure(t)
end
