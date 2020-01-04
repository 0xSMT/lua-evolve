local Util = require "util"

local roulette = function(minimize)
    minimize = minimize or false  
    return function(population, num_to_select)
        local total     = Util.sum(population, "fitness")
        local iter      = 1
        
        if minimize then
            vals = Util.foreach(population, function(x) return total / x["fitness"] end)
        else
            vals = Util.getall(population, "fitness")
        end

        local parents = {}

        for idx = 1, num_to_select do
            local randval   = math.random() * Util.sum(vals)
            local iter      = 0.0
            local curr_idx  = 0
            
            for i, v in ipairs(vals) do
                iter = iter + v
                curr_idx = i

                if iter > randval then
                    break
                end
            end

            table.insert(parents, population[curr_idx])
        end

        return parents
    end
end

-- local r = roulette(true)

-- local pop = {
--     {fitness = 50.0, data = 'a'},
--     -- {fitness = 10.0, data = 'b'},
--     {fitness = 25.0, data = 'c'},
--     {fitness = 25.0, data = 'd'}
-- } 

-- math.randomseed(os.time())

-- local children = {}
-- local calc = {a=0, b=0, c=0, d=0}

-- local LIM = 100000

-- for i = 1, LIM do
--     local p = r(pop)
--     table.insert(children, p.data)
--     calc[p.data] = calc[p.data] + 1
-- end

-- for k, v in pairs(calc) do
--     print(k, v / LIM)
-- end

-- print(table.unpack(children))

return roulette