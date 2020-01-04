local Util = {}
Util.__index = Util

function Util.draw(table)
    return table[math.random(#table)]
end

function Util.copy(table)
    local dup = {}
    
    for k, v in pairs(table) do 
        dup[k] = v 
    end
    
    return dup
end

function Util.sort(t, sorter)
    local dup = Util.copy(t)
    
    table.sort(dup, sorter)

    return dup
end

function Util.range(vals, key)
    if key == nil then
        local sorted = Util.sort(vals)
        return sorted[#sorted] - sorted[1]
    else
        local sorted = Util.sort(vals, function(a, b) return a[key] < b[key] end)
        return sorted[#sorted][key] - sorted[1][key]
    end
end

function Util.sum(vals, key)
    local sum = 0

    if key == nil then
        for _, v in pairs(vals) do
            sum = sum + v
        end
    else
        for _, v in pairs(vals) do
            sum = sum + v[key]
        end
    end
    
    return sum
end

function Util.normalize(vals, denom)
    denom = denom or Util.sum(vals)
    local normalized_vals = {}

    for i, v in pairs(vals) do
        normalized_vals[i] = v / denom
    end

    return normalized_vals
end

function Util.foreach(vals, lambda)
    local transformed = {}

    for i, v in pairs(vals) do
        transformed[i] = lambda(v)
    end

    return transformed
end

function Util.getall(vals, key)
    return Util.foreach(vals, function(v) return v[key] end)
end

function Util.shuffle(vals)
    local mixed = {}

    for i = 1, #vals do
        local rand_index = math.random(i)
        
        if rand_index ~= i then
            mixed[i] = mixed[rand_index]     
        end

        mixed[rand_index] = vals[i]
    end

    return mixed
end

-- math.randomseed(os.time())

-- local arr = {1,2,3}

-- for i = 1, 10 do
--     print(table.unpack(Util.shuffle(arr)))
-- end

return Util