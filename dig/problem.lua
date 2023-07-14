local problem = {
    scheduler = {}
}

function problem:set_scheduler()
    return function(scheduler)
        self.scheduler = scheduler
        return problem
    end
end

function problem:dig(direction, reason)
    if reason:find("Nothing to dig here") then
        -- non issue
        return
    end
    printError("cannot dig: " .. reason)

    if reason:find("unbreakable") then
        local original = self.scheduler:argument("direction")
        self.scheduler:argument("direction", direction)
        self.scheduler:run_now("problem:unbreakable")
        self.scheduler:argument("direction", original)
        return
    elseif reason:find("tool") then
        self.scheduler:run_now("problem:tool")
        return
    end

    printError("unresolvable reason. terminating")
    self.scheduler:insert("terminate")
end

function problem:move(direction, reason)
    printError("cannot move: " .. reason)

    if reason:find("obstructed") then
        local original = self.scheduler:argument("direction")
        self.scheduler:argument("direction", direction)
        self.scheduler:run_now("problem:obstructed")
        self.scheduler:argument("direction", original)
        return
    elseif reason:find("fuel") then
        local original = self.scheduler:argument("direction")
        self.scheduler:argument("direction", direction)
        self.scheduler:run_now("problem:fuel:empty")
        self.scheduler:argument("direction", original)
        self.scheduler:schedule_now("move:" .. direction)
        return
    end

    printError("unresolvable reason. terminating")
    self.scheduler:insert("terminate")
end

return problem:set_scheduler()
