# Note:
# I understand that there is a rockspec format for luarocks,
# but that seems overkill for what I actually need it to do:
# List dependencies and install them. This is file is a simpler way
# of doing that.

# Installation directory containing all the modules this project uses.
DIR_NAME=lua_modules

# Before installing, we should clear the tree (if it exists).
luarocks purge --tree $DIR_NAME

# Install dependencies locally, so LÖVE understands them.
luarocks install json4lua --tree $DIR_NAME
