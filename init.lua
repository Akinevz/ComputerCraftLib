local module = {}

module.id = "KineCraft Library"
module.version = "1.0.4"
module.repo = "github:akinevz/ComputerCraftLib"
module.file = "init.lua"
module.package = "main"

function module:fetchrepo(repoString)
    -- Split repo string into protocol and rest of string
    local protocol, repo = repoString:match("^(.-):(.-)$")

    -- Call correct function based on protocol
    local url
    if protocol == "pastebin" then
        url = self:fetch_pastebin(repo)
    elseif protocol == "github" then
        url = self:fetch_github(repo)
    else
        error("Invalid protocol in repo string")
    end

    return self:fetch(url, self.file)
end

function module:fetch_pastebin(pasteID)
    local url = "https://pastebin.com/raw/" .. pasteID
    return url
end

function module:fetch_github(repoString)
    -- Split repo string into protocol, user and repo
    local user, repo = repoString:match("(.-)/(.+)$")
    local file = self.file
    local url = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/master/" .. file
    return url
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

function module:install_version(dest)
    -- Get module version from file contents
    local version = self:get_version(dest:gsub(".lua", ""))

    -- Construct folder path
    local repoString = self.repo:gsub(":", "-")
    local folder = repoString .. "_" .. version

    -- Check if folder exists
    if not fs.exists(folder) then
        -- Create folder
        fs.makeDir(folder)
    end

    -- Move file into folder
    fs.move(dest, folder .. "/" .. filename)
    return folder .. "/" .. filename
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
    if shell.getRunningProgram() == self:provided() then
        return self
    else
        return self:autoupdate()
    end
end

return module:bootstrap()
