#!/bin/sh

# Note: This file should be run once.

__set_up_tyd_command() {
    sudo chmod u+x tools/tyd.lua
    RC_LOCATION=~/.${1}rc
    echo "export PATH=\"$PWD/tools:$PATH\"" >> $RC_LOCATION
    echo "alias tyd=\"tyd.lua\"" >> $RC_LOCATION
    ${1}
} 

echo "Where should I install the 'tyd' command?"
echo "Available options:"
echo " - zsh (~/.zshrc)"
echo " - bash (~/.bashrc)"
read LOCATION

while [ "$LOCATION" != "zsh" ] && [ "$LOCATION" != "bash" ]; do
    echo "That is not quite right, try again:"
    read LOCATION
done

echo "... Installing 'tyd' command..."

__set_up_tyd_command $LOCATION

echo "Installation complete!"
