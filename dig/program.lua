local program = {
    args = {},
    fns = {
        halt = {},
        terminate = {}
    },
    queue = {}
}
-- prelude

function program:argument(arg, val)
    if not val then
        return self.args[arg]
    end
    self.args[arg] = val
end

function program:argument_number(arg, val)
    if not val then
        return tonumber(self.args[arg])
    end
    self.args[arg] = tonumber(val)
end

function program:arguments(args)
    local present = true
    for _, arg in ipairs(args) do
        if self.args[arg] == nil then
            printError(arg .. " missing")
            present = false
        end
    end
    return present
end

function program:schedule(signal)
    print("scheduling " .. dump(signal))
    if not self.fns[signal] then
        printError("unknown signal: " .. signal)
        self:schedule_now("halt")
        return false
    end
    table.insert(program.queue, { event = signal })
    return true
end

function program:schedule_now(signals)
    if type(signals) == "table" then
        -- Insert multiple signals
        for idx, signal in ipairs(signals) do
            table.insert(self.queue, idx, { event = signal })
        end
    else
        -- Insert single signal
        table.insert(self.queue, 1, { event = signals })
    end
end

function program:run_now(signals)
    local state = self:save()

    if type(signals) == "table" then
        -- Handle multiple signals like schedule_now
        for idx, signal in ipairs(signals) do
            self:schedule(signal)
        end
    else
        -- Handle single signal
        self:schedule(signals)
    end

    local status = self:execute()

    self:restore(state)
    return status
end

function program:register(signal, func)
    if not func.cb then
        error(":register takes an object with field .cb (callback)")
    end
    self.fns[signal] = func.cb
end

function program:poll()
    local item = table.remove(program.queue, 1)
    if not item then
        error("attempting to execute past end of instructions")
    end
    local event = item.event
    if not event then
        error("polled {" .. dump(item) .. "}, invalid instruction")
    end
    return event
end

function program:clear()
    while #program.queue > 0 do
        local event = self:poll()
        print("removing " .. event)
    end
end

function program:save()
    local state = {}
    for _, item in ipairs(self.queue) do
        table.insert(state, item)
    end
    return state
end

function program:restore(state)
    self.queue = {}
    for _, item in ipairs(state) do
        table.insert(self.queue, item)
    end
end

function program:execute()
    while #program.queue > 0 do
        local signal = self:poll()
        print("processing event " .. signal)
        if signal == "halt" then
            printError("debug: return false")
            return false
        end
        if signal == "terminate" then
            program:clear()
            return true
        end
        local fn = program.fns[signal]
        if not fn then
            error("no instruction registered for signal " .. signal)
        end
        fn()
    end
    return true
end

return program
