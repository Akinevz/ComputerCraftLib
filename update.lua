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

local libpkg = {}

libpkg.package_dir = "/packages"
libpkg.startup_dir = "/startup"

function libpkg:repo_safe(repo)
    return repo:gsub(":", "-"):gsub("/", "-")
end

function libpkg:make_pkg(module)
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
    local package = self:make_pkg(repo)
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
    self:postinstall(repo)
end

function libpkg:postinstall(repo)
    local module = libfetch:file(repo, "module.lua")
    local package = self:make_pkg(repo)

    -- Check if module.startup is true
    for line in module:gmatch("[^\r\n]+") do
        if line:match("^module%.startup%s*=%s*true") then
            -- Get entry file from module.entry line
            local entry
            for line in module:gmatch("[^\r\n]+") do
                if line:match("^module%.entry%s*=%s*\"(.+)\"") then
                    entry = line:match("\"(.+)\"")
                    break
                end
            end

            -- Copy entry file to startup dir
            local src = package .. "/" .. entry
            local dest = self.startup_dir .. "/" .. entry
            fs.copy(src, dest)
            break
        end
    end
end

if arg[1] == "bootstrap" then
    libpkg:bootstrap()
elseif arg[1] == "install" then
    local package = arg[2]
    if package then
        libpkg:install(package)
    else
        libpkg:install("module.lua")
    end
end
