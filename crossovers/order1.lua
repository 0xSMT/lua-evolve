local order1 = function(chromosome_init)

    return function(p1, p2)
        local len = #p1.data
        assert(len == #p2.data)
        assert(len > 2)

        local slice1 = math.random(len - 2) + 1
        local slice2 = math.random(len - 2) + 1

        -- local slice1 = 3
        -- local slice2 = 7

        slice1, slice2 = math.min(slice1, slice2), math.max(slice1, slice2)

        local child1 = {}
        local child2 = {}

        local used1 = {}
        local used2 = {}

        for i = slice1, slice2 do
            child1[i] = p1.data[i]
            child2[i] = p2.data[i]

            used1[child1[i]] = true
            used2[child2[i]] = true
        end

        local index1, index2 = slice2 + 1, slice2 + 1
        for i = 1, len do
            index = (slice2 + i) % (len) + 1

            if not used1[p2.data[index]] then
                child1[index1] = p2.data[index]
                used1[p2.data[index]] = true
                index1 = (index1 + 1) % (len + 1)
                if index1 == 0 then index1 = 1 end
            end

            if not used2[p1.data[index]] then
                child2[index2] = p1.data[index]
                used2[p1.data[index]] = true
                index2 = (index2 + 1) % (len + 1)
                if index2 == 0 then index2 = 1 end
            end
        end

        child1 = chromosome_init(child1)
        child2 = chromosome_init(child2)

        return {child1, child2}
    end
end

-- math.randomseed(os.time())

-- local function c_init(arr)
--     return {data = arr}
-- end

-- local p1 = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'}
-- local p2 = {'c', 'f', 'a', 'j', 'h', 'd', 'i', 'g', 'b', 'e'}

-- p1, p2 = c_init(p1), c_init(p2)

-- local ord1 = order1(c_init)

-- local c1, c2 = ord1(p1, p2)

-- print(table.unpack(c1.data))
-- print(table.unpack(c2.data))

return order1