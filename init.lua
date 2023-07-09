local module = {}

module.id = "KineCraft Library"
module.package = "module"
module.file = "init.lua"
module.provides = "module/init"
module.version = "1.0.2"
module.repo = "github:akinevz/ComputerCraftLib"

function module:provided()
    return self.provides .. ".lua"
end

function module:fetch(url, filename)
    -- Download file from URL
    local resp = http.get(url)
    local file = resp.readAll()

    -- Write to local file system
    local downloads = self.package
    if not fs.exists(downloads) then
        fs.makeDir(downloads)
    end

    local dest = downloads .. "/" .. filename
    local f = fs.open(dest, "w")
    f.write(file)
    f.close()
    return dest
end

function module:fetchrepo(repoString)
    -- Split repo string into protocol and rest of string
    local protocol, repo = repoString:match("^(.-):(.-)$")

    -- Call correct function based on protocol
    if protocol == "pastebin" then
        return self:fetch_pastebin(repo)
    elseif protocol == "github" then
        return self:fetch_github(repo)
    else
        error("Invalid protocol in repo string")
    end
end

function module:fetch_pastebin(pasteID)
    local url = "https://pastebin.com/raw/" .. pasteID
    return self:fetch(url, self.file)
end

function module:fetch_github(repoString)
    -- Split repo string into protocol, user and repo
    local user, repo = repoString:match("(.-)/(.+)$")
    local file = self.file
    local url = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/master/" .. file
    return self:fetch(url, file)
end

function module:install_version(dest)
    -- Get module version from file contents
    local version = self:get_version(self.provides)

    -- Construct folder path
    local repoString = self.repo:gsub(":", "-")
    local folder = repoString .. "_" .. version

    -- Check if folder exists
    if not fs.exists(folder) then
        -- Create folder
        fs.makeDir(folder)
    end

    -- Move file into folder
    if not fs.exists(dest) then
        fs.move(self.cache, dest, true)
    end
    return dest
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

function module:autoupdate()
    print("performing autoupdate")

    local provided = self:provided()
    if fs.exists(provided) then
        fs.delete(provided)
    end

    -- Get repo URL from module object
    local repo = self.repo

    -- fetch latest module.lua from the repo
    local dest = self:fetchrepo(repo)

    -- install latest version
    local installed = self:install_version(dest)

    -- create soft link to the installed file
    local startup = "startup/31_startup.lua"
    if fs.exists(startup) then
        fs.delete(startup)
    end

    fs.copy(installed, startup)
end

function module:bootstrap()
    self:autoupdate()

    return self
end

return module:bootstrap()
