local module = {}

module.id = "KineCraft Library"
module.file = "init"
module.version = "1.1"
module.cache = module.file .. ".lua"
module.repo = "github:akinevz/ComputerCraftLib"


function module:install_version()
    -- Get module version from file contents
    local version = self:get_version(self.file)

    -- Construct folder path
    local folder = self.repo .. "_" .. version

    -- Check if folder exists
    if not fs.exists(folder) then
        -- Create folder
        fs.makeDir(folder)
    end

    -- Move file into folder
    local dest = folder .. "/" .. self.cache
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
    local url = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/master/module.lua"
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

function module:bootstrap()
    -- Check if file is being run directly
    if _G == _G then
        -- Run autoupdate()
        print("performing autoupdate")
        self:autoupdate()
    end

    return self
end

function module:autoupdate()
    -- Get repo URL from module object
    local repo = self.repo

    if fs.exists(self.file) then
        fs.delete(self.file)
    end

    -- fetch latest module.lua from the repo
    self:fetchrepo(repo)

    -- install latest version
    local installed = self:install_version()

    -- create soft link to the installed file
    local startup = "startup/01_os.lua"
    if fs.exists(startup) then
        fs.delete(startup)
    end

    fs.copy(installed, startup)
end

return module:bootstrap()
