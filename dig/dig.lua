-- declarations

local scheduler = require("scheduler")

scheduler:register("program:arguments", {
    cb = function()
        printError("program is missing arguments")
        scheduler:clear()
    end
})

local movement = require("movement")

local inventory = require("inventory")

local mining = require("mining")

local program = {
    fuel_distance = 0
}

function program:schedule_layer()
    scheduler:postpone("program:layer:begin")
    scheduler:postpone("program:layer")
    scheduler:postpone("program:layer:end")
end

function program:goto_origin()
    scheduler:postpone("gps:save")
    scheduler:postpone("program:minimise:depth")
    scheduler:postpone("program:minimise:x")
    scheduler:postpone("move:turn")
    scheduler:postpone("program:minimise:y")
end

scheduler:register("program:minimise:depth", {
    cb = function()
        if movement.gps:depth() > 0 then
            print("depth " .. movement.gps:depth())
            scheduler:insert({ "move:up", "program:minimise:depth" })
        end
    end
})

scheduler:register("program:minimise:x", {
    cb = function()
        if movement.gps:x() > 0 then
            scheduler:insert({ "move:forward", "program:minimise:x" })
        end
    end
})

scheduler:register("program:minimise:y", {
    cb = function()
        if movement.gps:y() > 0 then
            scheduler:insert({ "move:forward", "program:minimise:y" })
        end
    end
})

-- function program:goto_saved()

-- end

scheduler:register("program:excavate", {
    cb = function()
        if not scheduler:arguments({"depth", "direction", "diameter"}) then
            scheduler:insert("program:arguments")
            return
        end
        local depth = scheduler:argument_number("depth")
        local gps_depth = movement.gps:depth()
        if gps_depth < tonumber(depth) then
            program:schedule_layer()
            scheduler:postpone("program:excavate")
            return
        end
        scheduler:postpone("program:goto_origin")
    end
})

scheduler:register("program:layer:begin", {
    cb = function()
        mining:down()
        movement:down()
    end
})

scheduler:register("program:layer:end", {
    cb = function()
        movement:turn()
        local direction = scheduler:argument("direction")
        if direction == "right" then
            scheduler:argument("direction", "left")
        elseif direction == "left" then
            scheduler:argument("direction", "right")
        end
    end
})

scheduler:register("program:layer", {
    cb = function()
        local diameter = scheduler:argument_number("diameter")
        local direction = scheduler:argument("direction")
        -- for each col
        for i = 1, diameter - 1 do
            for j = 1, diameter - 1 do
                mining:forward()
                movement:forward()
            end
            movement:turn(direction)
            mining:forward()
            movement:forward()
            movement:turn()
            if direction == "right" then
                direction = "left"
            elseif direction == "left" then
                direction = "right"
            end
        end
        for j = 1, diameter - 1 do
            mining:forward()
            movement:forward()
        end
    end
})

-- scheduler:register("program:goto_origin", {
--     cb = function()
--         program:goto_origin()
--     end
-- })


-- scheduler:register("program:goto_saved", {
--     cb = function()
--         program:goto_saved()
--     end
-- })

-- scheduler:register("inventory:empty_loot", {
--     cb = function()
--         inventory:empty_loot()
--     end
-- })

scheduler:register("inventory:fuel", {
    cb = function()
        program.fuel_distance = inventory:total_fuel()
    end
})

scheduler:register("recovery:forward", {
    cb = function()
        local mined, reason = mining:forward()
        if not mined then
            printError(reason)
            scheduler:insert("halt")
        end
        local moved, reason = movement:forward()
        if not moved then
            printError(reason)
            scheduler:insert("halt")
        end
    end
})

scheduler:register("recovery:up", {
    cb = function()
        local mined, reason = mining:up()
        if not mined then
            printError(reason)
            scheduler:insert("halt")
        end
        local moved, reason = movement:up()
        if not moved then
            printError(reason)
            scheduler:insert("halt")
        end
    end
})

scheduler:register("recovery:down", {
    cb = function()
        local mined, reason = mining:down()
        if not mined then
            printError(reason)
            scheduler:insert("halt")
        end
        local moved, reason = movement:down()
        if not moved then
            printError(reason)
            scheduler:insert("halt")
        end
    end
})

scheduler:register("move:forward", {
    cb = function()
        local moved, reason = movement:forward()
    end
})

scheduler:register("move:up", {
    cb = function()
        local moved, reason = movement:up()
    end
})

scheduler:register("move:down", {
    cb = function()
        local moved, reason = movement:down()
    end
})

scheduler:register("move:right", {
    cb = function()
        movement:right()
    end
})

scheduler:register("move:left", {
    cb = function()
        movement:left()
    end
})

scheduler:register("move:turn", {
    cb = function()
        movement:turn()
    end
})

scheduler:register("move:counterturn", {
    cb = function()
        movement:opposite()
    end
})

scheduler:register("gps:save", {
    cb = function()
        movement.gps:save()
    end
})

scheduler:register("dig:forward", {
    cb = function()
        mining:forward()
    end
})

scheduler:register("dig:up", {
    cb = function()
        mining:up()
    end
})

scheduler:register("dig:down", {
    cb = function()
        mining:down()
    end
})



-- arguments

-- local diameter = tonumber(arg[1])
-- local direction = arg[2] or "right"
-- local depth = (arg[3])

-- if not diameter then
--     printError("please specify diameter of the dig")
--     return
-- end

-- if not (direction == "right" or direction == "left") then
--     printError("please specify direction (right|left)")
--     return
-- end

-- if not tonumber(depth) and not depth == "max" then
--     printError("please specify depth number or max")
--     return
-- end

-- local max_depth = tonumber(depth) or math.huge

local function run_excavate()
    scheduler:arguments({ diameter = diameter, direction = direction, depth = max_depth })
    scheduler:postpone("program:excavate")
    scheduler:execute()
end

local function run_repl()
    local running = true
    while running do
        local line = read()
        if line:match("^%a+=%S+") then
            local arg, val = line:match("^(%a+)=(.+)$")
            scheduler:argument(arg, val)
        else
            running = scheduler:run(line) and running
        end
    end
end

-- run_excavate()
run_repl()
