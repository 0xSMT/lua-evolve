local Util = {}
Util.__index = Util

function Util.draw(table)
    return table[math.random(#table)]
end

function Util.range(vals)
    return math.max(table.unpack(vals)) - math.min(table.unpack(vals))
end

return Util