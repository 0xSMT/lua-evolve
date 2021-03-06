local order2 = function(chromosome_init, num_pts)
    num_pts = num_pts or 2 -- 2 seems to work the best, and higher numbers are worse
    return function(p1, p2)
        local len = #p1
        assert(len == #p2)

        local used_pts = {}
        -- local pts = {}

        local basis1 = {pts = {}}
        local basis2 = {pts = {}}

        -- print(p1, p2)

        -- local test_pts = {3, 4, 7, 9}

        for i = 1, num_pts do
            local pt = 0

            repeat
                pt = math.random(len)
            until not used_pts[pt]
            -- pt = test_pts[i]

            used_pts[pt] = true

            table.insert(basis1, p1[pt])
            table.insert(basis2, p2[pt])

            basis1.pts[p1[pt]] = true
            basis2.pts[p2[pt]] = true
        end

        local index1 = 1
        local index2 = 1

        local child1 = {}
        local child2 = {}

        for i = 1, len do
            if basis1.pts[p2[i]] then
                table.insert(child1, basis1[index1])
                index1 = index1 + 1
            else
                table.insert(child1, p2[i])
            end

            if basis2.pts[p1[i]] then
                table.insert(child2, basis2[index2])
                index2 = index2 + 1
            else
                table.insert(child2, p1[i])
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

-- local ord2 = order2(c_init)

-- local c1, c2 = ord2(p1, p2)

-- print(table.unpack(c1.data))
-- print(table.unpack(c2.data))

return order2