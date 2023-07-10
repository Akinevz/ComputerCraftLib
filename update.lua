local module = {}

module.id = "KineCraft OS"
module.repo = "github:akinevz/ComputerCraftLib"
module.entry = "update.lua"
module.build = 4

local function sanitise_repo_name(repo)
    return repo:gsub(":", "-"):gsub("/", "-")
end

local libfetch = {}

function libfetch:github(repoString)
    -- Split repo string into protocol, user and repo
    local user, repo = repoString:match("(.-)/(.+)$")
    local file = module.entry
    local url = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/master/" .. file
    return url
end

function libfetch:pastebin(pasteId)
    local url = "https://pastebin.com/raw/" .. pasteId
    return url
end

function libfetch:get(url)
    -- Download file from URL
    print("Downloading " .. url)
    local resp = http.get(url)
    local text = resp.readAll()

    return text
end

local libfresh = {}

function libfresh:install(content, folder, filename)
    -- Create folder if it doesn't exist
    if not fs.exists(folder) then
        fs.makeDir(folder)
    end

    local dest = (folder .. "/" .. filename)
    -- Open file for writing
    local file = fs.open(dest, "w")

    -- Write text to file
    file.write(content)

    -- Close file
    file.close()

    -- Return output filename
    return dest
end

function libfresh:get_module_version(file)
    -- Open file
    local f = fs.open(file, "r")

    -- Read lines until we find the build line
    local line = f.readLine()
    while line do
        if line:match("^build%s*=%s*(%d+)") then
            -- Get version number from build line
            local version = tonumber(line:match("%d+"))
            f.close()
            return version
        end
        line = f.readLine()
    end

    -- If no build line found, return 0
    f.close()
    return 0
end

function libfresh:build_repo_url(repo)
    local protocol, url = repo:match("^(.-):(.-)$")

    -- Call correct function based on protocol
    if protocol == "pastebin" then
        return libfetch:pastebin(url)
    elseif protocol == "github" then
        return libfetch:github(url)
    else
        error("Invalid protocol in repo string")
    end
end

function libfresh:fetch_latest(repo)
    local url = self:build_repo_url(repo)
    -- todo: download and return the version number
    local text = libfetch:get(url)
    local installed_tmp = self:install(text, "/tmp", sanitise_repo_name(repo))
    local installed_tmp_version = self:get_module_version(installed_tmp)

    return installed_tmp, installed_tmp_version
end

function libfresh:fetch_local(repo)
    local package_name = sanitise_repo_name(repo)
    local versions = {}

    -- Get list of files in /repos
    local files = fs.list(self:install_location())

    -- Find all files starting with package_name
    for _, file in ipairs(files) do
        if file:match("^" .. package_name .. "%.(%d+)") then
            table.insert(versions, tonumber(file:match("%d+")))
        end
    end

    -- Return highest version number
    local installed_version 
    for _, version in ipairs(versions) do
        if not installed_version or version > installed_version then
            installed_version = version
        end
    end

    return package_name, installed_version
end

function libfresh:register(file, packageName, version)
    local install_dest = self:install_location() .. "/" .. packageName .. "." .. version
    if fs.exists(install_dest) then
        error("Version " .. version .. " of " .. packageName .. " already exists")
    end
    fs.makeDir(install_dest)
    fs.move(file, install_dest .. "/" .. module.entry)
end

function module:initialise()
    -- Check entry file exists in startup
    if not self:autostart_exists() then
        self:autostart_register()
    end

    -- Check startup folder exists
    if not fs.exists("/startup") then
        -- Install mbs dependency
        shell.run("wget https://raw.githubusercontent.com/SquidDev-CC/mbs/master/mbs.lua mbs.lua")
        shell.run("mbs.lua install")
        os.reboot()
    end

    -- Run autoupdate routine
    local tmp, tmp_version = libfresh:fetch_latest(self.repo)
    local installed, installed_version = libfresh:fetch_local(self.repo)

    debug.debug("tmp", tmp)
    debug.debug("installed", installed)
end

function libfresh:startup_entry()
    return "/startup/" .. module.entry
end

function libfresh:install_location()
    return "/repos"
end

function module:autostart_register()
    -- Get current program filename
    local filename = shell.getRunningProgram()

    -- Move current program to startup folder
    fs.move(filename, libfresh:startup_entry())
end

function module:autostart_exists()
    return fs.exists(libfresh:startup_entry())
end

return module:initialise()
