local Util = require "util"

local roulette = function(minimize)
    minimize = minimize or false  
    return function(population)
        local total     = Util.sum(population, "fitness")
        local iter      = 1
        
        if minimize then
            vals = Util.foreach(population, function(x) return total / x["fitness"] end)
        else
            vals = Util.getall(population, "fitness")
        end

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

        return population[curr_idx]
    end
end

return roulette