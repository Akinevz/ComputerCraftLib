local module = {}

module.id = "KineCraft Library"
module.version = "0.1"
module.cache = "incoming.http"
module.repo = "github:akinevz/ComputerCraftLib"

function module:install_version(file)
    -- Get module version from file contents
    local f = fs.open(file, "r")
    local contents = f.readAll()
    f.close()
    local version = self:get_version(contents)

    -- Construct folder path
    local folder = self.repo .. "_" .. version

    -- Check if folder exists
    if not fs.exists(folder) then
        -- Create folder
        fs.makeDir(folder)
    end

    -- Move file into folder
    fs.move(file, folder .. "/" .. file)
end

function module:get_version(file)
    -- Require file
    local mod = require(file)

    -- Check mod has id
    if not mod.id then
        error("Mod is missing id property")
    end

    -- Check mod has version
    if not mod.version then
        error("Mod is missing version property")
    end

    -- Get version from module object
    local version = mod.version

    -- Return version
    return version
end

function module:fetchrepo(repoString)
    -- Split repo string into protocol and rest of string
    local protocol, repo = repoString:match("^(.-):(.-)$")

    -- Call correct function based on protocol
    if protocol == "pastebin" then
        self:fetch_pastebin(repo)
    elseif protocol == "github" then
        self:fetch_github(repo)
    else
        error("Invalid protocol in repo string")
    end
end

function module:fetch_pastebin(pasteID)
    local url = "https://pastebin.com/raw/" .. pasteID
    self:fetch(url, self.cache)
end

function module:fetch_github(repoString)
    -- Split repo string into protocol, user and repo
    local user, repo = repoString:match("(.-)/(.+)$")
    local url = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/master/init.lua"
    self:fetch(url, self.cache)
end

function module:fetch(url, filename)
    -- Download file from URL
    local resp = http.get(url)
    local file = resp.readAll()

    -- Write to local file system
    local f = fs.open(filename, "w")
    f.write(file)
    f.close()
end

function module:autoupdate()
end

function module:bootstrap()
end

return module
