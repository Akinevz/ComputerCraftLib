local scheduler = {
    args = {},
    fns = {
        halt = {}
    },
    queue = {}
}
-- prelude

local function dump(o)
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

function scheduler:argument(arg, val)
    if not val then
        return self.args[arg]
    end
    self.args[arg] = val
end

function scheduler:argument_number(arg, val)
    if not val then
        return tonumber(self.args[arg])
    end
    self.args[arg] = tonumber(val)
end

function scheduler:arguments(args)
    local present = true
    for _, arg in ipairs(args) do
        if self.args[arg] == nil then
            printError(arg .. " missing")
            present = false
        end
    end
    return present
end

function scheduler:insert(signals)
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

function scheduler:postpone(signal)
    print("postponing " .. signal)
    if not self.fns[signal] then
        printError("unknown: " .. signal)
        return false
    end
    table.insert(scheduler.queue, { event = signal })
    return true
end

function scheduler:register(signal, func)
    if not func.cb then
        error(":register takes an object with field .cb (callback)")
    end
    self.fns[signal] = func.cb
end

function scheduler:run(signal)
    if self:postpone(signal) then
        return self:execute()
    end
    return true
end

function scheduler:poll()
    local item = table.remove(scheduler.queue, 1)
    if not item then
        error("attempting to execute past end of instructions")
    end
    local event = item.event
    if not event then
        error("polled {" .. dump(item) .. "}, invalid instruction")
    end
    return event
end

function scheduler:clear()
    while #scheduler.queue > 0 do
        local event = self:poll()
        print("removing " .. event)
    end
end

function scheduler:execute()
    while #scheduler.queue > 0 do
        local signal = self:poll()
        print("processing event " .. signal)
        if signal == "halt" then
            return false
        end
        local fn = scheduler.fns[signal]
        if not fn then
            error("no instruction registered for signal " .. signal)
        end
        fn()
    end
    return true
end

return scheduler
