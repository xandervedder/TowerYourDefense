#!/usr/bin/env lua

--[[
    Script that is used to run certain tools in the TowerYourDefense project.

    This script is automatically available as a command after running `install.sh`.
]]--

---@type string
local commandToRun = arg[1]

if commandToRun == nil then
    print("No command specified.")
    print("See 'tyd help'.")
    return;
end

if commandToRun == "help" then
    print("- help:")
    print("  Displays this screen.")
    print()

    print("- install:")
    print("  Installs all luarocks packages.")
    print()

    print("- test:")
    print("  Runs all the tests within the TowerYourDefense project.")
    print("  Indicates whether the tests have failed or not.")
    print()
elseif commandToRun == "install" then
    local dirName = "lua_modules"

    os.execute("luarocks purge --tree " .. dirName)
    os.execute("luarocks install lunajson --tree " .. dirName)
    os.execute("luarocks install luaunit --tree " .. dirName)
elseif commandToRun == "test" then
    os.execute("lua $PWD/test/runner.lua")
else
    print("Command not recognized: '" .. commandToRun .. "'.")
end
