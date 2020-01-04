local insertion = function(chromosome_init)
    num_pts = 1
    return function(chromosome)
        local len = #chromosome
        assert(len > 0)

        local pt1 = math.random(len)
        local pt2 = 0

        repeat
            pt2 = math.random(len)
        until pt2 ~= pt1

        local data = {}

        for i = 1, len do
            data[i] = chromosome[i]
        end

        local val = table.remove(data, pt1)
        table.insert(data, pt2, val)

        return chromosome_init(data)
    end
end

-- math.randomseed(os.time())

-- local function c_init(arr)
--     return {data = arr}
-- end

-- local old = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'}

-- old = c_init(old)

-- local ins = insertion(c_init)

-- local mut = ins(old.data)

-- print(table.unpack(mut.data))

return insertion