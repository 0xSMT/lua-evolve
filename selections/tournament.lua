local Util = require "util"

local tournament = function(minimize, fit_select_rate)
    minimize        = minimize or false  
    fit_select_rate = fit_select_rate or .075
    return function(population)
        local popsize = #population
        
        local p1 = population[math.random(popsize)]
        local p2 = population[math.random(popsize)]

        local rand = math.random()

        if not minimize and rand < fit_select_rate or rand > fit_select_rate then -- select more maximizing individual
            if p1.fitness > p2.fitness then 
                return p1
            else
                return p2
            end
        else -- select less maximizing individual
            if p1.fitness > p2.fitness then 
                return p2
            else
                return p1
            end
        end
    end
end

return tournament