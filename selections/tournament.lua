local Util = require "util"

local tournament = function(minimize, fit_select_rate)
    minimize        = minimize or false  
    fit_select_rate = fit_select_rate or .8
    return function(population, num_to_select)
        local popsize = #population
        
        local parents = {}

        for idx = 1, num_to_select do
            local p1 = population[math.random(popsize)]
            local p2 = population[math.random(popsize)]

            local rand = math.random()

            if not minimize and rand < fit_select_rate or rand > fit_select_rate then -- select more maximizing individual
                if p1.fitness > p2.fitness then 
                    table.insert(parents, p1)
                else
                    table.insert(parents, p2)
                end
            else -- select less maximizing individual
                if p1.fitness > p2.fitness then 
                    table.insert(parents, p2)
                else
                    table.insert(parents, p1)
                end
            end
        end

        return parents
    end
end

return tournament