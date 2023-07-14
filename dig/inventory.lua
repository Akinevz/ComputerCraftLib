local inventory = {
    fuel_slots = {},
    loot_slots = {},
}

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

function inventory:select(n)
    return turtle.select(n)
end

function inventory:drop()
    return turtle.drop()
end

function inventory:is_fuel()
    return turtle.refuel(0) and turtle.getItemCount() > 1
end

function inventory:stack_size()
    return turtle.getItemCount()
end

function inventory:is_loot()
    return not self:is_fuel() and turtle.getItemCount() > 0
end

function inventory:scan()
    local fuel_slots = {}
    local loot_slots = {}

    for i = 1, 16 do
        self:select(i)
        if self:is_fuel() then
            table.insert(fuel_slots, { fuel = i })
        end
        if self:is_loot() then
            table.insert(loot_slots, { loot = i })
        end
    end

    self:select(1)

    print(dump(fuel_slots))

    self.fuel_slots = fuel_slots
    self.loot_slots = loot_slots
end

function inventory:dump()
    while #self.loot_slots > 0 do
        local loot = table.remove(self.loot_slots).loot
        self:select(loot)
        self:drop()
    end
    self:select(1)
end

function inventory:refuel(distance)
    if not distance then
        return self:measure_fuel()
    end

    while #self.fuel_slots > 0 do
        local slot = table.remove(self.fuel_slots).fuel

        self:select(slot)

        local per_energy = self:refuel()

        local remaining = self:stack_size()

        local available = remaining - 1
        if distance == math.huge then
            return self:measure_fuel(available)
        end

        local to_completion = distance / per_energy

        local to_use = math.min(available, to_completion)

        distance = distance - self:measure_fuel(to_use)
    end

    return not (distance > 0)
end

function inventory:measure_fuel(n)
    local before = turtle.getFuelLevel()
    turtle.refuel(n or 1)
    local after = turtle.getFuelLevel()
    return after - before
end

return inventory
