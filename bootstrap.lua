local function wget(path, url, ...)
    shell.run("wget " .. url .. " " .. path)
    local args = { ... }
    for _, arg in ipairs(args) do
        shell.run(arg)
    end
end

local function dependency(path)
    return fs.exists(path)
end

local function clean(path)
    if fs.exists(path) then
        fs.delete(path)
    end
end

if not arg[1] then
    if not dependency("/mbs.lua") then
        -- Install mbs dependency (provider of /startup)
        local mbs = "https://raw.githubusercontent.com/SquidDev-CC/mbs/master/mbs.lua"
        wget("/mbs.lua", mbs, "/mbs.lua install")
    end

    if not dependency("/update.lua") then
        local bootstrap = "https://raw.githubusercontent.com/akinevz/ComputerCraftLib/master/update.lua"
        wget("/update.lua", bootstrap, "/update.lua bootstrap")
    end

    -- cleanup script
    fs.delete(shell.getRunningProgram())

    print("Press Y to update and reboot (any key to cancel)")
    local event, userinput = os.pullEvent("char")
    local userinput = string.upper(userinput)
    if userinput == "Y" then
        os.reboot()
    end
elseif arg[1] == "clean" then
    clean("/update.lua")
    clean("/mbs.lua")
    clean("/startup")
    clean("/packages")
else
    error("Invalid argument")
end
