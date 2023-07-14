-- todo: use serialisation to store 3 bits per move
local gps = {
    angle = 0,
    last_turn = "right",
    bearing = "north",
    origin = {
        x = 0, y = 0, z = 0
    },
    saved = {
        x = 0, y = 0, z = 0, angle = 0
    }
}


local move = {
    gps = gps,
    problem = {}
}

function move:set_dependencies()
    return function(problem)
        self.problem = problem
        return move
    end
end

function move:forward()
    local moved, reason = turtle.forward()
    if not moved then
        return self.problem:move("forward", reason)
    end
    gps:forward()
    return moved, reason
end

function move:up()
    local moved, reason = turtle.up()
    if not moved then
        return self.problem:move("up", reason)
    end
    gps:up()
    return moved, reason
end

function move:down()
    local moved, reason = turtle.down()
    if not moved then
        return self.problem:move("down", reason)
    end
    gps:down()
    return moved, reason
end

function move:right()
    turtle.turnRight()
    gps:right()
end

function move:left()
    turtle.turnLeft()
    gps:left()
end

function move:turn(direction)
    if not direction then
        if gps.last_turn == "right" then
            self:right()
        elseif gps.last_turn == "left" then
            self:left()
        end
        return
    end
    if direction == "right" then
        self:right()
    elseif direction == "left" then
        self:left()
    end
end

function move:opposite()
    if gps.last_turn == "right" then
        self:left()
    elseif gps.last_turn == "left" then
        self:right()
    end
end

function gps:depth()
    return math.abs(self.origin.z)
end

function gps:x()
    return math.abs(self.origin.x)
end

function gps:y()
    return math.abs(self.origin.y)
end

function gps:manhattan()
    return math.abs(self.origin.x) + math.abs(self.origin.y)
end

function gps:to_origin()
    return self:depth() + self:manhattan()
end

function gps:turn(degrees)
    local new_angle = self.angle + degrees
    if new_angle >= 360 then
        new_angle = new_angle - 360
    elseif new_angle < 0 then
        new_angle = 360 + new_angle
    end
    self.angle = new_angle
end

function gps:down()
    self.origin.z = self.origin.z - 1
end

function gps:up()
    self.origin.z = self.origin.z + 1
end

function gps:forward()
    if self.bearing == "north" then
        self.origin.y = self.origin.y - 1
    elseif self.bearing == "east" then
        self.origin.x = self.origin.x - 1
    elseif self.bearing == "south" then
        self.origin.y = self.origin.y + 1
    elseif self.bearing == "west" then
        self.origin.x = self.origin.x + 1
    end
end

function gps:right()
    self.last_turn = "right"
    if self.bearing == "north" then
        self.bearing = "east"
    elseif self.bearing == "east" then
        self.bearing = "south"
    elseif self.bearing == "south" then
        self.bearing = "west"
    elseif self.bearing == "west" then
        self.bearing = "north"
    end
    self:turn(90)
end

function gps:left()
    self.last_turn = "left"
    if self.bearing == "north" then
        self.bearing = "west"
    elseif self.bearing == "west" then
        self.bearing = "south"
    elseif self.bearing == "south" then
        self.bearing = "east"
    elseif self.bearing == "east" then
        self.bearing = "north"
    end
    self:turn(-90)
end

function gps:save()
    self.saved.x = self.origin.x
    self.saved.y = self.origin.y
    self.saved.z = self.origin.z
    self.saved.angle = self.angle
end

return move:set_dependencies()
