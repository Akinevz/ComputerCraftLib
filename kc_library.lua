-- terminal object
local genericTerminal = term.current()



-- create a new window
local kc_Window = function(x, y, w, h)
    return window.create(genericTerminal, x, y, w, h)
end

-- convert user/repo string to github url
local function to_githubURL(url)
    return "https://github.com/" .. url
end

local function Module(name, url)
    
end

-- object managing the loading and unloading of modules
local function ControlCenter(url)
    local module = Module("ControlCenter", url)
    return module
end

-- operating system routines
local KineCraft_Routines = {
    welcome = function()
        local controlCenter = ControlCenter("akinevz/computer")

    end,
    checkWeather = function(window, words)
        local weather = words.weather
        window.write(weather)
    end,
    header = function()
        local width, height = 20, 5
        local lWindow = kc_Window(1, 1, width, height)
        return lWindow
    end,
    body = function()
        local width, height = 20, 5
        local lWindow = kc_Window(1, 1 + height, width, height)
        return lWindow
    end,
    github = to_githubURL,
}

return {
    words = KineCraft_Words,
    routines = KineCraft_Routines,
}
