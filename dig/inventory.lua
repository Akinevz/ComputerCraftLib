local api = {
    fuel_slots = {},
    free_slots = {},
    mined = 0,
    dig = {}
}

function api:select(n)
    turtle.select(n)
end

function api:drop()
    turtle.drop()
end

function api:is_fuel()
    return turtle.refuel(0) and turtle.getItemCount() > 1
end

function api:is_free()
    return turtle.getItemCount() == 0
end

function api:scan()
    local fuel_slots = {}
    local free_slots = {}

    for i = 1, 16 do
        self:select(i)
        if self:is_fuel() then
            table.insert(fuel_slots, { fuel = i })
        end
        if self:is_free() then
            table.insert(free_slots, { free = i })
        end
    end

    self:select(1)

    self.fuel_slots = fuel_slots
    self.free_slots = free_slots
end

function api:slot_fuel()
    local pre = turtle.getFuelLevel()
    turtle.refuel(1)
    local post = turtle.getFuelLevel()
    return post - pre
end

function api:total_fuel()
    self:scan()
    local total = 0
    for _, slot in ipairs(self.fuel_slots) do
        self:select(slot)
        local count = turtle.getItemCount()
        total = total + (count * self:slot_fuel())
    end
    self:select(1)
    return total
end

function api:wait_fuel()
    while #self.fuel_slots == 0 do
        printError("no fuel found in inventory")
        os.pullEvent("turtle_inventory")
        api:scan()
    end
end

function api:empty_loot()

end

return api
