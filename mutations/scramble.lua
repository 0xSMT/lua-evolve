local Util = require 'util'

local scramble = function(chromosome_init)
    return function(chromosome)
        local len = #chromosome

        local pt1 = math.random(len)
        local pt2 = 0

        repeat
            pt2 = math.random(len)
        until pt2 ~= pt1

        pt1, pt2 = math.min(pt1, pt2), math.max(pt1, pt2)

        -- pt1, pt2 = 3, 8

        local slice = {}

        for i = pt1, pt2 do
            slice[i - pt1 + 1] = chromosome[i]
        end

        local mixed = Util.shuffle(slice)
        local data = {}

        for i = 1, pt1 - 1 do
            data[i] = chromosome[i]
        end

        for i = pt1, pt2 do
            data[i] = mixed[i - pt1 + 1]
        end

        for i = pt2 + 1, len do
            data[i] = chromosome[i]
        end

        return chromosome_init(data)
    end
end

-- math.randomseed(os.time())

-- local function c_init(arr)
--     return {data = arr}
-- end

-- local old = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'}

-- old = c_init(old)

-- local ins = scramble(c_init)

-- local mut = ins(old.data)

-- print(table.unpack(mut.data))

return scramble