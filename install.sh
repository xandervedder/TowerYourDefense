#!/bin/sh

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
luarocks install lunajson --tree $DIR_NAME
luarocks install luaunit --tree $DIR_NAME

# After installing all the packages, we need to know where the user
# wants the helper commands to go (`bashrc`, or `zshrc`).

__install_test_alias() {
    # TODO: change the way this works...
    RC_LOCATION=~/.${1}rc
    echo "alias tyd:test='$1 tools/test.sh'" >> $RC_LOCATION
} 

echo "Where should I put the aliases?"
echo "Available options:"
echo " - zsh (~/.zshrc)"
echo -e " - bash (~/.bashrc)\n"
read LOCATION

while [ "$LOCATION" != "zsh" ] && [ "$LOCATION" != "bash" ]; do
    echo "That is not quite right, try again:"
    read LOCATION
done

echo "... Installing 'tyd:test' --> Runs all tests."

__install_test_alias $LOCATION

echo "Installation complete!"
$LOCATION
