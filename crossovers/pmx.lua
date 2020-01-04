local Util = require 'util'

local pmx = function(chromosome_init)

    return function(p1, p2)
        local len = #p1
        assert(len == #p2)
        assert(len > 2)

        local slice_pt1 = math.random(len - 2) + 1
        local slice_pt2 = math.random(len - 2) + 1

        -- local slice_pt1 = 3
        -- local slice_pt2 = 6

        slice_pt1, slice_pt2 = math.min(slice_pt1, slice_pt2), math.max(slice_pt1, slice_pt2)
        print(slice_pt1, slice_pt2)

        local child1, child2    = {}, {}
        local conflicts         = {}

        local map               = {}
        local used1, used2      = {}, {}

        for i = slice_pt1, slice_pt2 do
            child1[i] = p2[i]
            child2[i] = p1[i]

            used1[p2[i]] = true
            used2[p1[i]] = true

            -- map1[p1[i]] = p2[i] -- parent1 to parent2
            -- map2[p2[i]] = p1[i] -- parent2 to parent1

            if map[p1[i]] ~= nil or map[p2[i]] ~= nil then
                conflicts[p1[i]] = true
                conflicts[p2[i]] = true
                
                if map[p1[i]] ~= nil then conflicts[map[p1[i]]] = true end  
                if map[p2[i]] ~= nil then conflicts[map[p2[i]]] = true end

                map[p1[i]] = nil
                map[p2[i]] = nil
            else
                map[p1[i]] = p2[i]
                map[p2[i]] = p1[i]
            end
            -- print(p1[i], p2[i])
        end
        
        local indices1, indices2 = {}, {}
        for i = 1, len do
            if i < slice_pt1 or i > slice_pt2 then
                local m1 = map[p1[i]]
                local m2 = map[p2[i]]

                -- print(m1, m2)
                -- print(p1[i], m1, conflicts[m1])
                -- print(p2[i], m2, conflicts[m2])
                -- print()

                if conflicts[p1[i]] then
                    table.insert(indices1, i)
                    child1[i] = -1
                elseif m1 == nil then
                    child1[i] = p1[i]
                    used1[p1[i]] = true
                else
                    child1[i] = m1
                    used1[m1] = true
                end

                if conflicts[p2[i]] then
                    table.insert(indices2, i)
                    child2[i] = -1
                elseif m2 == nil then
                    child2[i] = p2[i]
                    used2[p2[i]] = true
                else
                    child2[i] = m2
                    used2[m2] = true
                end
            end
        end

        local i1, i2 = 1, 1
        for k, _ in pairs(conflicts) do
            print(k)
            if not used1[k] then
                child1[indices1[i1]] = k
                i1 = i1 + 1
            end

            if not used2[k] then
                child2[indices2[i2]] = k
                i2 = i2 + 1
            end
        end

        -- print(table.unpack(child1))
        -- print(table.unpack(child2))

        child1 = chromosome_init(child1)
        child2 = chromosome_init(child2)

        return {child1, child2}
    end
end

math.randomseed(os.time())

local function c_init(arr)
    return {data = arr}
end

local function randvec(numval)
    local t = {}

    for i = 1, numval do
        table.insert(t, i)
    end

    return Util.shuffle(t)
end

-- print(table.unpack(randvec(10)))

local p1 = randvec(100)
local p2 = randvec(100)

p1, p2 = c_init(p1), c_init(p2)

local pmx = pmx(c_init)

local children = pmx(p1.data, p2.data)

c1 = children[1]
c2 = children[2]

print(table.unpack(c1.data))
print(table.unpack(c2.data))

return pmx