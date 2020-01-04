local PPP = require 'ppp'
local SA = require 'sa'

-- assert(arg[1], "NO MUTATION PROVIDED")
-- assert(arg[2], "NO SELECTION PROVIDED")
-- assert(arg[3], "NO CROSSOVER PROVIDED")
-- assert(arg[4], "NO PROBLEM PROVIDED")

function evo_sa(mut, prob, outfile, foolish)
    local mutation  = require('mutations/' .. mut)
    local flot = require 'flot'

    math.randomseed(os.time())

    local problem = PPP.parse(prob)
    local ppp = PPP.start(problem, {fn = mutation, rate = 0.05, min_rate = 0.05, max_rate = 0.05}, crossover, selection)

    local ideal_table = problem.graph.pts
    local ideal = ppp.chromosome(ideal_table)
    local ideal_fit = ppp.fitness.feasible(ideal.chromosome)

    local sa_args = {
        alpha   = 0.99,
        beta    = 1.01,
        t0      = 50,
        i0      = 50
    }

    local sa = SA.new(ppp)

    local ipop_gen = function() return PPP.init_population(1, problem)[1] end 
    local elite, log = sa:run(ipop_gen, sa_args, foolish, 5 * 60, true)

    -- print(dump(elite.chromosome))
    local file = io.open("./output_sa/" .. outfile .. "_log.txt", "w")
    print("./output_sa/" .. outfile .. "_log.txt")

    file:write("FINAL\t" .. elite.fitness .. "\n")
    file:write("IDEAL\t" .. ideal_fit .. "\n")
    -- print(dump(ideal.chromosome))

    file:write("ITERS\t" .. log.iterations .. "\n")
    file:write("MAX PERCENT OF STATE SPACE EXPLORED\t" .. (log.iterations * 1) ..  "/" .. (problem.rows * problem.cols) .. "!\n")
    file:write("TIME\t" .. log.time)

    file:close()

    local ideal_fitness = {}
    for i = 1, log.iterations do
        table.insert(ideal_fitness, {i, ideal_fit})
    end

    -- PLOTTING
    local plot = flot.Plot {
        legend = { position = "ne"}
    }

    plot:add_series("Elite Fitness", log.best_fitness)
    plot:add_series("Best Solution", ideal_fitness)
    plot:add_series("Current Fitness", log.curr_fitness)
    -- plot:add_series("True Elite Fitness", log.true_elite_fitness)

    flot.render(plot, "output_sa/" .. outfile)

    -- consider eliminating the best of the population for some period, let he system evolve, and reintroduce later. Have a 'true' best and a 'local'best
end

local mutations = {"tbe", "pairwise"}

local prob_prefix = "./problems/toy_grid_"
local prob_suffix = ".json"

local problems = {"4x4", "5x5", "5x6", "block12x12"}

local fools = {false, true}

local repetitions = 5

for _, foolish in ipairs(fools) do
    for _, mut in ipairs(mutations) do
        for _, prob in ipairs(problems) do
            local problem = prob_prefix .. prob 

            for rep = 1, repetitions do
                local output_name = (foolish and "foolish" or "sa") .. "_" .. mut .. "_" .. prob .. "_" .. tostring(rep) .. prob_suffix
                print("EXEC: " .. output_name)

                evo_sa(mut, problem .. prob_suffix, output_name, foolish)
            end
        end
    end
end
