local PPP = require 'ppp'
local SGA = require 'sga'

-- assert(arg[1], "NO MUTATION PROVIDED")
-- assert(arg[2], "NO SELECTION PROVIDED")
-- assert(arg[3], "NO CROSSOVER PROVIDED")
-- assert(arg[4], "NO PROBLEM PROVIDED")

function evo(mut, sel, crx, prob, outfile)
    local mutation  = require('mutations/' .. mut)
    local selection = require('selections/' .. sel)
    local crossover = require('crossovers/' .. crx)
    local flot = require 'flot'

    math.randomseed(os.time())

    local problem = PPP.parse(prob)
    local ppp = PPP.start(problem, {fn = mutation, rate = 0.05, min_rate = 0.05, max_rate = 0.05}, crossover, selection)
    ppp.stagnation_threshold = 20000 -- 2000 generations with no change is a term condition

    local ideal_table = problem.graph.pts
    local ideal = ppp.chromosome(ideal_table)
    local ideal_fit = ppp.fitness.feasible(ideal.chromosome)

    local termination_conditions = {
        ["maxtime"] = 60 * 5, -- five minutes
        ["maxiter"] = 10000, -- five thousand generationas
        ["minintv"] = -1,
        ["ideal"]   = ideal_fit
    }

    local evo = SGA.new(ppp)

    local popsize = 50

    local ipop_gen = function() return PPP.init_population(popsize, problem) end 
    local elite, log = evo:run(ipop_gen, termination_conditions, true)

    -- print(dump(elite.chromosome))
    local file = io.open("./output/" .. outfile .. "_log.txt", "w")
    print("./output/" .. outfile .. "_log.txt")

    file:write("FINAL\t" .. elite.fitness .. "\n")
    file:write("IDEAL\t" .. ideal_fit .. "\n")
    -- print(dump(ideal.chromosome))

    file:write("ITERS\t" .. log.generations .. "\n")
    file:write("MAX PERCENT OF STATE SPACE EXPLORED\t" .. (log.generations * popsize) ..  "/" .. (problem.rows * problem.cols) .. "!\n")
    file:write("TIME\t" .. log.time)

    file:close()

    local ideal_fitness = {}
    for i = 1, log.generations do
        table.insert(ideal_fitness, {i, ideal_fit})
    end

    -- PLOTTING
    local plot = flot.Plot {
        legend = { position = "ne"}
    }

    plot:add_series("Elite Fitness", log.best_fitness)
    plot:add_series("Best Solution", ideal_fitness)
    plot:add_series("Average Fitness", log.average_fitness)
    -- plot:add_series("True Elite Fitness", log.true_elite_fitness)

    flot.render(plot, "output/" .. outfile)

    -- consider eliminating the best of the population for some period, let he system evolve, and reintroduce later. Have a 'true' best and a 'local'best
end

local selections = {"tournament", "roulette"}
local mutations = {"tbe", "pairwise"}
local crossovers = {"order2", "order1"}

local prob_prefix = "./problems/toy_grid_"
local prob_suffix = ".json"

local problems = {"4x4", "5x5", "5x6"}

local repetitions = 5

for _, mut in ipairs(mutations) do
    for _, sel in ipairs(selections) do
        for _, crx in ipairs(crossovers) do
            for _, prob in ipairs(problems) do
                local problem = prob_prefix .. prob 

                for rep = 1, repetitions do
                    local output_name = mut .. "_" .. sel .. "_" .. crx .. "_" .. prob .. "_" .. tostring(rep) .. prob_suffix
                    print("EXEC: " .. output_name)

                    evo(mut, sel, crx, problem .. prob_suffix, output_name)
                end
            end
        end
    end
end
