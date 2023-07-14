local mining = {
    troubleshoot = {}
}

function mining:set_dependencies()
    return function(troubleshoot)
        self.troubleshoot = troubleshoot
        return mining
    end
end

function mining:forward()
    local success, reason = turtle.dig()
    if not success then
        self.troubleshoot:dig("forward", reason)
    end
    return success, reason
end

function mining:up()
    local success, reason = turtle.digUp()
    if not success then
        self.troubleshoot:dig("up", reason)
    end
    return success, reason
end

function mining:down()
    local success, reason = turtle.digDown()
    if not success then
        self.troubleshoot:dig("down", reason)
    end
    return success, reason
end

return mining:set_dependencies()
