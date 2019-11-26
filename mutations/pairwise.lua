local pairwise = function(chromosome_init)

    return function(chromosome)
        local len = #chromosome.data

        local pt1 = math.random(len)
        local pt2 = 0

        repeat
            pt2 = math.random(len)
        until pt2 ~= pt1

        assert( pt1 ~= pt2)

        local data = {}

        for i = 1, len do
            data[i] = chromosome.data[i]
        end

        data[pt1] = chromosome.data[pt2]
        data[pt2] = chromosome.data[pt1]

        return chromosome_init(data)
    end
end

-- math.randomseed(os.time())

-- local function c_init(arr)
--     return {data = arr}
-- end

-- local old = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'}

-- old = c_init(old)

-- local pwise = pairwise(c_init)

-- local mut = pwise(old)

-- print(table.unpack(mut.data))

return pairwise