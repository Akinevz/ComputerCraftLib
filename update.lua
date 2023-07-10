local libfetch = {}

function libfetch:get(url)
    -- Download file from URL as string
    local resp = http.get(url)
    if not resp then
        error("url " .. url .. " returned no response")
    end
    local text = resp.readAll()

    return text
end

function libfetch:save(content, dir, filename)
    -- Create folder if it doesn't exist
    if not fs.exists(dir) then
        fs.makeDir(dir)
    end

    local dest = dir .. "/" .. filename

    -- Open file for writing
    local file = fs.open(dest, "w")

    -- Write text to file
    file.write(content)

    -- Close file
    file.close()

    -- Return output filename
    return dest
end

function libfetch:github(repoString, file)
    -- Split repo string into user and repo
    local user, repo = repoString:match("(.-)/(.+)$")
    local url = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/master/" .. file
    return self:get(url)
end

function libfetch:pastebin(pasteId)
    local url = "https://pastebin.com/raw/" .. pasteId
    return self:get(url)
end

function libfetch:file(repo, file)
    local protocol, url = repo:match("^(.-):(.-)$")

    -- Call correct function based on protocol
    if protocol == "pastebin" then
        return libfetch:pastebin(url)
    elseif protocol == "github" then
        return libfetch:github(url, file)
    else
        error("Invalid protocol in repo string")
    end
end

function libfetch:dependencies(dir)
    local module_path = dir .. "/module.lua"
    local f = fs.open(module_path, "r")
    local content = f.readAll()
    f.close()

    -- Get dependencies from module.lua content
    local dependencies = {}
    for line in content:gmatch("[^\r\n]+") do
        if line:match("^module%.dependencies%s*=%s*%{") then
            local dep_list = line:match("%{(.+)}%s*$")
            for dep in dep_list:gmatch("\"(.-)\",?") do
                table.insert(dependencies, dep)
            end
        end
    end

    return dependencies
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
    print("Installed " .. dest)
    return dest
end

function libfresh:version(content)

end

-- function libfresh:local_version()
--     -- local versions are installed to /packages
--     local package_name = self:repo_name()
--     local versions = {}

--     -- Get list of files in /packages
--     local files = fs.list(self:install_location())

--     -- Find all files starting with package_name
--     for _, file in ipairs(files) do
--         if file:match("^" .. package_name .. "%.(%d+)") then
--             table.insert(versions, tonumber(file:match("%d+")))
--         end
--     end

--     -- Return highest version number
--     local installed_version
--     for _, version in ipairs(versions) do
--         if not installed_version or version > installed_version then
--             installed_version = version
--         end
--     end

--     return installed_version
-- end

-- function libfresh:fetch_latest(repo, entry)
--     local content = libfetch:file(repo, entry)

--     local version = self:version(content)
--     local installed = self:local_version()
--     if not version > installed then
--         return installed
--     end

--     local dest = self:install_location() .. "/" .. module:repo_name() .. "." .. version
--     self:install(content, dest, entry)
--     -- Install dependencies
--     for _, dep in ipairs(module.dependencies) do
--         local dep_content = libfetch:file(repo, dep)
--         self:install(dep_content, dest, dep)
--     end

--     return version
-- end

local libpkg = {}

libpkg.package_dir = "/packages"
libpkg.startup_dir = "/startup"

function libpkg:repo_safe(repo)
    return repo:gsub(":", "-"):gsub("/", "-")
end

function libpkg:package_dir(module)
    local dir = self.package_dir .. "/" .. self:repo_safe(module)
    if not fs.exists(dir) then
        fs.makeDir(dir)
    end
    return dir
end

function libpkg:bootstrap()
    self:download("github:akinevz/ComputerCraftLib")
end

function libpkg:download(repo)
    local module = libfetch:file(repo, "module.lua")
    local package = self:package_dir(repo)
    libfetch:save(module, package, "module.lua")
    local dependencies = libfetch:dependencies(package)
    for _, depname in ipairs(dependencies) do
        local dep = libfetch:file(repo, depname)
        libfetch:save(dep, package, depname)
    end
end

function libpkg:extract_repo(content)
    -- Get repo from module.repo line
    local repo
    for line in content:gmatch("[^\r\n]+") do
        if line:match("^module%.repo%s*=%s*\"(.+)\"") then
            repo = line:match("\"(.+)\"")
            break
        end
    end
    return repo
end

function libpkg:extract_build(content)
    -- Get version from module.build line
    for line in content:gmatch("[^\r\n]+") do
        if line:match("^module.build%s*=%s*(%d+)") then
            -- Get version number from build line
            local version = tonumber(line:match("%d+"))
            return version
        end
    end

    -- If no build line found, return 0
    return 0
end

function libpkg:install(pkgfile)
    local f = fs.open(pkgfile, "r")
    if not f then
        error("Pkgfile " .. pkgfile .. " does not exist")
    end
    local content = f.readAll()
    f.close()

    local repo = self:extract_repo(content)
    -- Call self:install passing the repo
    self:download(repo)
end

if arg[1] == "bootstrap" then
    libpkg:bootstrap()
elseif arg[1] == "install" then
    local package = arg[2]
    libpkg:install(package)
end