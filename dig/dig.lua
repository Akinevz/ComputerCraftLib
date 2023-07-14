function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-- declarations

local program = require("program")

local problem = require("problem")(program)

local inventory = require("inventory")

local movement = require("movement")(problem)

local mining = require("mining")(problem)

-- problem

program:register("problem:arguments", {
    cb = function()
        printError("program is missing arguments")
        program:schedule_now("terminate")
    end
})

-- todo: make generator
program:register("problem:space", {
    cb = function()
        program:run_now({ "goto:origin", "inventory:scan", "inventory:dump", "goto:restore" })
    end
})

program:register("problem:chest", {
    cb = function()
        printError("no chest detected")
        program:schedule_now({ "turn", "turn", "terminate" })
    end
})

program:register("problem:fuel:empty", {
    cb = function()
        printError("please place fuel into the inventory")
        os.pullEvent("turtle_inventory")
        program:run_now("inventory:scan")
        program:run_now("inventory:refuel")
    end
})

program:register("problem:fuel:low", {
    cb = function()
        program:run_now("inventory:scan")
        local no_fuel = #inventory.fuel_slots == 0
        if no_fuel then
            program:run_now("problem:fuel:empty")
            return
        end
        program:schedule_now("inventory:refuel")
    end
})

program:register("problem:obstructed", {
    cb = function()
        local direction = program:argument("direction")
        if direction == "up" then
            if mining:up() then
                movement:up()
            end
            return
        end
        if direction == "down" then
            if mining:down() then
                movement:down()
            end
            return
        end
        if direction == "forward" then
            if mining:forward() then
                movement:forward()
            end
            return
        end
    end
})

program:register("problem:tool", {
    cb = function()
        print("please equip a valid tool with equip:right or equip:left")
        program:schedule_now("terminate")
    end
})

program:register("problem:unbreakable", {
    cb = function()
        local direction = program:argument("direction")
        if direction == "up" then
            printError("irrecoverable position: bedrock above turtle")
            program:schedule("terminate")
            return
        end
        if direction == "down" then
            printError("warning: bedrock below turtle")
            program:schedule("goto:origin")
            return
        end
        if direction == "forward" then
            printError("warning: bedrock in front of turtle")
            program:schedule("goto:origin")
            return
        end
    end
})

-- program

program:register("program:return", {
    cb = function()
        program:argument("distance", movement.gps:to_origin())
        program:schedule("inventory:scan")
        program:schedule("inventory:refuel")
        program:schedule("goto:origin")
        program:schedule("inventory:dump")
    end
})

program:register("program:excavate", {
    cb = function()
        if not program:arguments({ "depth", "direction", "diameter" }) then
            program:schedule_now("problem:arguments")
            return
        end
        local depth = program:argument_number("depth")
        local diameter = program:argument_number("diameter")
        local gps_depth = movement.gps:depth()

        program:argument_number("distance", diameter * diameter * depth)

        if gps_depth < depth then
            program:schedule("program:layer:begin")
            program:schedule("program:layer")
            program:schedule("program:layer:end")
            program:schedule("program:excavate")
            return
        end
        program:schedule("program:return")
    end
})

program:register("program:layer:begin", {
    cb = function()
        mining:down()
        movement:down()
    end
})

program:register("program:layer:end", {
    cb = function()
        movement:turn()
        local direction = program:argument("direction")
        if direction == "right" then
            program:argument("direction", "left")
        elseif direction == "left" then
            program:argument("direction", "right")
        end
    end
})

program:register("program:layer", {
    cb = function()
        local diameter = program:argument_number("diameter")
        local direction = program:argument("direction")
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

local function goto_origin()
    program:schedule_now({ "gps:save", "program:minimise:depth", "program:minimise:x", "program:minimise:y" })
end

program:register("goto:origin", {
    cb = function()
        goto_origin()
    end
})

-- todo: reset alignment

program:register("program:minimise:depth", {
    cb = function()
        if movement.gps:depth() > 0 then
            print("depth " .. movement.gps:depth())
            program:schedule_now({ "move:up", "program:minimise:depth" })
        end
    end
})

program:register("program:minimise:x", {
    cb = function()
        if movement.gps:x() > 0 then
            program:schedule_now({ "move:forward", "program:minimise:x" })
        end
    end
})

program:register("program:minimise:y", {
    cb = function()
        if movement.gps:y() > 0 then
            program:schedule_now({ "move:forward", "program:minimise:y" })
        end
    end
})

-- todo: restore alignment
local function goto_restore()
    program:schedule("program:restore:angle")
    program:schedule("program:restore:depth")
    program:schedule("program:restore:x")
    program:schedule("program:restore:y")
end

program:register("goto:restore", {
    cb = function()
        goto_restore()
    end
})

program:register("program:restore:depth", {
    cb = function()
        if movement.gps:depth() > 0 then
            print("depth " .. movement.gps:depth())
            program:schedule_now({ "move:up", "program:minimise:depth" })
        end
    end
})

program:register("program:restore:x", {
    cb = function()
        if movement.gps:x() > 0 then
            program:schedule_now({ "move:forward", "program:minimise:x" })
        end
    end
})

program:register("program:restore:y", {
    cb = function()
        if movement.gps:y() > 0 then
            program:schedule_now({ "move:forward", "program:minimise:y" })
        end
    end
})

program:register("program:restore:angle", {
    cb = function()
        printError("unimplemented program:restore:angle")
        program:schedule_now("halt")
    end
})

-- move

program:register("move:forward", {
    cb = function()
        local moved, reason = movement:forward()
    end
})

program:register("move:up", {
    cb = function()
        local moved, reason = movement:up()
    end
})

program:register("move:down", {
    cb = function()
        local moved, reason = movement:down()
    end
})

program:register("move:right", {
    cb = function()
        movement:right()
    end
})

program:register("move:left", {
    cb = function()
        movement:left()
    end
})

program:register("move:turn", {
    cb = function()
        movement:turn()
    end
})

program:register("move:counterturn", {
    cb = function()
        movement:opposite()
    end
})

-- gps

program:register("gps:save", {
    cb = function()
        movement.gps:save()
    end
})

-- dig

program:register("dig:forward", {
    cb = function()
        mining:forward()
    end
})

program:register("dig:up", {
    cb = function()
        mining:up()
    end
})

program:register("dig:down", {
    cb = function()
        mining:down()
    end
})

-- inventory

program:register("inventory:scan", {
    cb = function()
        inventory:scan()
    end
})

program:register("inventory:dump", {
    cb = function()
        local has, block = turtle.detect()
        if has and block.name:find("chest") then
            inventory:dump()
            program:schedule("turn")
            program:schedule("turn")
        else
            program:schedule_now("problem:chest")
        end
    end
})

program:register("inventory:refuel", {
    cb = function()
        local distance = program:argument("distance") or 1
        print("trying to refuel for distance: " .. distance)
        local full_refuel = inventory:refuel(distance)
        if not full_refuel then
            program:schedule("problem:fuel:low")
        end
    end
})

program:register("print:fuel", {
    cb = function()
        local fuel = turtle.getFuelLevel()
        print("Fuel level: " .. fuel)
    end
})

-- equip

program:register("equip:left", {
    cb = function()
        turtle.equipLeft()
    end
})

program:register("equip:right", {
    cb = function()
        turtle.equipRight()
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
    program:arguments({ diameter = diameter, direction = direction, depth = max_depth })
    program:schedule("program:excavate")
    program:execute()
end

local function run_repl()
    local running = true
    while running do
        local line = read()
        if line:match("^%a+=%S+") then
            local arg, val = line:match("^(%a+)=(.+)$")
            program:argument(arg, val)
        else
            running = program:run_now(line) and running
        end
    end
end

-- run_excavate()
run_repl()
