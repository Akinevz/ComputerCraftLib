local modloader = {}
local log = require("kc_log")

function modloader.downloadMod(url)
    -- Download mod file from GitHub URL
    local resp = http.get(url)
    local mod = resp.readAll()

    -- Check for dependencies in mod file
    local dependencies = {}
    for line in mod:gmatch("[^\r\n]+") do
        if line:match("^%s*%-%-DEPENDENCIES:%s*(.+)") then
            dependencies = { string.split(line:match("%-%-DEPENDENCIES:%s*(.+)"), "%s*,%s*") }
        end
    end

    -- Download dependency mods
    for _, dep in ipairs(dependencies) do
        modloader.downloadMod("https://raw.githubusercontent.com/" .. dep)
    end

    -- Return mod code
    return mod
end

function modloader.loadMod(name, url)
    log.logTop(string.format("Downloading mod %s from %s", name, url))

    if not modloader.hasMeta(url) then
        log.logNext(string.format("Repo does not have %s", "meta.lua"))
        return
    end

    -- Download mod from URL
    local mod = modloader.downloadMod(url)

    -- Create mod environment
    local env = setmetatable({}, { __index = _G })

    -- Run mod in environment
    assert(load(mod, "=" .. name, "t", env))()

    -- Export mod environment
    _G[name] = env
end

function modloader.hasMeta(repo)
    local url = "https://raw.githubusercontent.com/" .. repo .. "/master/meta.lua"
    local resp = http.get(url)
    if resp.getResponseCode() == 200 then
        return true
    else
        return false
    end
end

return modloader
