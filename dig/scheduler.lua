local scheduler = {
    args = {},
    fns = {},
    queue = {}
}

function scheduler:argument(arg, val)
    if not val then
        return self.args[arg]
    end
    self.args[arg] = val
end

function scheduler:arguments(args)
    self.args = args
end

function scheduler:register(signal, func)
    if not func.cb then
        error(":register takes an object with field .cb (callback)")
    end
    self.fns[signal] = func.cb
end

function scheduler:postpone(signal)
    print("postponing " .. signal)
    table.insert(scheduler.queue, { event = signal })
end

function scheduler:next()
    return table.remove(scheduler.queue, 1)
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

function scheduler:execute()
    while #scheduler.queue > 0 do
        local event = table.remove(scheduler.queue, 1).event
        if event == "halt" then
            break
        end
        print("processing event "..event)
        local fn = scheduler.fns[event]
        fn()
    end
end

return scheduler
