local PPP = require 'ppp'
local SGA = require 'sga'

assert(arg[1], "NO MUTATION PROVIDED")
assert(arg[2], "NO SELECTION PROVIDED")
assert(arg[3], "NO CROSSOVER PROVIDED")
assert(arg[4], "NO PROBLEM PROVIDED")
-- assert(arg[5], "NO MUTATION RATE PROVIDED")

local mutation  = require('mutations/' .. arg[1])
local selection = require('selections/' .. arg[2])
local crossover = require('crossovers/' .. arg[3])
local flot = require 'flot'

math.randomseed(os.time())

local problem = PPP.parse(arg[4])
local ppp = PPP.start(problem, {fn = mutation, rate = 0.05, min_rate = 0.05, max_rate = 0.05}, crossover, selection)
ppp.stagnation_threshold = 2000

local termination_conditions = {
   ["maxtime"] = 60 * 5,
   ["maxiter"] = math.huge,
   ["minintv"]  = -1
}

local evo = SGA.new(ppp)

local popsize = 50

local ipop_gen = function() return PPP.init_population(popsize, problem) end 
local elite, log = evo:run(ipop_gen, termination_conditions, true)

local ideal_table = problem.graph.pts
local ideal = ppp.chromosome(ideal_table)
local ideal_fit = ppp.fitness.feasible(ideal.chromosome)

-- print(dump(elite.chromosome))
print("FINAL\t" .. elite.fitness)
print("IDEAL\t" .. ideal_fit)
-- print(dump(ideal.chromosome))

print("ITERS\t" .. log.generations)
print("MAX PERCENT OF STATE SPACE EXPLORED\t" .. (log.generations * popsize) ..  "/" .. (problem.rows * problem.cols) .. "!")

local ideal_fitness = {}
for i = 1, log.generations do
   table.insert(ideal_fitness, {i, ideal_fit})
end

-- PLOTTING
local plot = flot.Plot {
   legend = { position = "ne"}
}

plot:add_series("Local Elite Fitness", log.best_fitness)
plot:add_series("Best Solution", ideal_fitness)
plot:add_series("Average Fitness", log.average_fitness)
plot:add_series("True Elite Fitness", log.true_elite_fitness)

flot.render(plot, "plots/fitness")

-- consider eliminating the best of the population for some period, let he system evolve, and reintroduce later. Have a 'true' best and a 'local'best