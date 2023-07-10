local module = {}

module.id = "KineCraft OS Updater"
module.repo = "github:akinevz/ComputerCraftLib"
module.build = 12
module.startup = true
module.entry = "update.lua"
module.dependencies = { "bootstrap.lua", "package.lua" }

return module
