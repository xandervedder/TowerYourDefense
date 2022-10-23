# Tower Your Defense

This is an attempt at creating a fun and innovative [Tower Defense](https://en.wikipedia.org/wiki/Tower_defense) game.

Most Tower Defense games get rather repetitive and only restrict towers to a few predefined types that each have their own purpose, like shooting at flying enemies.

This game takes a different approach to towers. Its system is similar to [GemCraft](https://store.steampowered.com/app/296490/GemCraft__Chasing_Shadows/), though more expanded upon the concept (in contrast to the original GemCraft). In the case of this game, it will be possible to alter the tower to your preference (enemy group, damage output, and more...).

Another big difference with all the other Tower Defense games, is that you will have to collect resources to make said towers, similar to an RTS. You will also be able to walk around and enter different vehicles (made with resources).

This ofcourse, is my vision for this game. Whether it gets completed depends entirely on myself.

## Features and what is being worked on

To see what is being worked on, the following Trello board can be used to see what I'm currently working on: https://trello.com/b/jOEa64gb/toweryourdefense. 

Do note that progress is pretty slow, since I am working on this in my free time and the fact that I am not familiar with developing games (in LÖVE with Lua, but also in general).

## Run

This game uses [LÖVE](https://love2d.org/). For now, the game can be run with `love .` (just be sure you have LÖVE installed).

For development purposes, there is a `setup.sh` that can be run. This will 'install' the `tyd` command.
For now this is limited to the following (more to come):
 - `tyd install`, installs all packages necessary to run the game.
 - `tyd test`, runs all the tests.
