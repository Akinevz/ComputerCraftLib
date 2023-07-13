local mining = {
    mined_blocks = 0
}

local recovery = require("recovery")

function mining:forward()
    local success, reason = turtle.dig()
    if success then
        mining.mined_blocks = mining.mined_blocks + 1
    end
    return success, reason
end

function mining:up()
    local success, reason = turtle.digUp()
    if success then
        mining.mined_blocks = mining.mined_blocks + 1
    end
    return success, reason
end

function mining:down()
    local success, reason = turtle.digDown()
    if success then
        mining.mined_blocks = mining.mined_blocks + 1
    end
    return success, reason
end

function mining:mined()
    return mining.mined_blocks
end

return mining
