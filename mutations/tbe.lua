local twobondswap = function(chromosome_init)

    return function(chromosome)
        local len = #chromosome.data

        local pt1 = math.random(len)
        local pt2 = 0

        repeat
            pt2 = math.random(len)
        until pt2 ~= pt1

        pt1, pt2 = math.min(pt1, pt2), math.max(pt1, pt2)

        local data = {}

        for i = 1, pt1 - 1 do
            data[i] = chromosome.data[i]
        end

        for i = pt1, pt2 do
            data[i] = chromosome.data[pt1 + (pt2 - i)]
        end

        for i = pt2 + 1, len do
            data[i] = chromosome.data[i]
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

-- local tbe = twobondswap(c_init)

-- local mut = tbe(old)

-- print(table.unpack(mut.data))

return twobondswap