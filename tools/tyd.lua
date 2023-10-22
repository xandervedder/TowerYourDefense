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

    print("- bundle:")
    print("  Bundles the game into a Windows executable (other binaries not supported yet).")
    print()
elseif commandToRun == "install" then
    local dirName = "lua_modules"
    local packages = {
        "lunajson",
        "luaunit",
    }

    -- Purge all packages first.
    os.execute("luarocks purge --tree " .. dirName)

    -- Then install every package.
    for _, package in pairs(packages) do
        os.execute("luarocks install " .. package .. " --tree " .. dirName)
    end
elseif commandToRun == "test" then
    os.execute("lua $PWD/test/runner.lua -o tap")
elseif commandToRun == "bundle" then
    print("Cleaning bin directory")
    os.execute("rm -r bin")
    os.execute("mkdir bin")
    print("Cleaing directory complete!")

    print("downloading Windows binaries...")
    os.execute("curl https://github.com/love2d/love/releases/download/11.4/love-11.4-win64.zip -o bin/binaries.zip -J -L")
    os.execute("unzip bin/binaries.zip -d bin/")
    print("downloading Windows binaries complete!")

    print("Generating love file...")
    os.execute("zip -q -r bin/TowerYourDefense.love . -x " ..
        "\"bin/*\" " ..
        "\"bundle/*\" " ..
        "\"lua_modules/*\" " ..
        "\"test/*\" " ..
        "\"tools/*\" " ..
        "\".vscode/*\" " ..
        "\".gitignore\" " ..
        "\"setup.sh\" " ..
        "\"profiler.*\" " ..
        "\".git/*\" " ..
        "\".DS_Store\"")
    -- Unfortunately it seems like LÖVE parses requires before the `conf.lua`, but I am not sure about that.
    -- If it didn't, this wouldn't be needed when bundling the file.
    os.execute("cd lua_modules/share/lua/5.4/ && zip -q -r ../../../../bin/TowerYourDefense.love .")
    print("Generating love file complete!")

    print("Fusing with love executable...")
    os.execute("cat bin/love-11.4-win64/love.exe bin/TowerYourDefense.love > bin/TowerYourDefense.exe")
    os.execute("rm bin/TowerYourDefense.love")
    print("Fusing with love executable complete!")

    print("Zipping game files...")
    os.execute("mv bin/love-11.4-win64/ bin/TowerYourDefense")
    os.execute("mv bin/TowerYourDefense.exe bin/TowerYourDefense/")
    os.execute("zip -r -j bin/TowerYourDefense.zip bin/TowerYourDefense/")
    os.execute("rm bin/binaries.zip && rm -r bin/TowerYourDefense/")
    print("Zipping game files complete!")
else
    print("Command not recognized: '" .. commandToRun .. "'.")
end
