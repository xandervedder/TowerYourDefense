# Installation directory containing all the modules this project uses.
DIR_NAME=lua_modules

# Install dependencies locally, so LÖVE understands them.
luarocks install json4lua --tree $DIR_NAME
